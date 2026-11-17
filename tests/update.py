import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import tomllib


root = Path(__file__).resolve().parents[1]
config = tomllib.loads((root / 'mise.linux.toml').read_text())

with tempfile.TemporaryDirectory() as directory:
    home = Path(directory)
    scripts = home / '.local/bin'
    scripts.mkdir(parents=True)
    shutil.copy(root / '.local/bin/dotfiles-update', scripts)
    patcher = home / 'github/casualjim/pi-mimir/packages/pi-hindsight/patch-dist.mjs'
    patcher.parent.mkdir(parents=True)
    (scripts / 'dotfiles-update-check').write_text('''
import json
import os
from pathlib import Path
ROOT = Path(os.environ['HOME'])
STATE = ROOT / '.local/state'
def collect_updates():
    return json.loads(os.environ['UPDATES']), json.loads(os.environ['ERRORS'])
''')
    stub = home / 'stub'
    stub.write_text('''#!/bin/sh
command="$0"
command="${command##*/}"
if [ "$#" -gt 0 ]; then command="$command $*"; fi
printf '%s\\n' "$command" >> "$LOG"
if [ "$command" = 'mise run pi-mimir-sync' ] && [ "$PATCHER_CHANGED" = 1 ]; then
  printf 'new patcher' > "$PATCHER"
fi
if [ "$command" = "$FAIL" ]; then exit 42; fi
''')
    stub.chmod(0o755)
    for name in ('arch-update', 'mise', 'podman', 'noctalia', 'npx', 'codebase-memory-mcp'):
        (scripts / name).symlink_to(stub)

    def row(id):
        return {'id': id, 'name': id.split(':', 1)[1], 'description': '',
                'from_version': 'old', 'to_version': 'new'}

    def run(ids=(), errors=(), fail='', patcher_changed=False):
        log = home / 'log'
        patcher.write_text('old patcher')
        log.write_text('')
        env = dict(os.environ, HOME=str(home), PATH=str(scripts), LOG=str(log), FAIL=fail,
                   PATCHER=str(patcher), PATCHER_CHANGED=str(int(patcher_changed)),
                   UPDATES=json.dumps([row(id) for id in ids]), ERRORS=json.dumps(errors))
        result = subprocess.run([sys.executable, str(scripts / 'dotfiles-update')],
                                cwd=home, env=env, capture_output=True, text=True)
        return result, log.read_text().splitlines()

    result, commands = run()
    assert result.returncode == 0 and not commands, (result.stderr, commands)
    assert 'No updates' in result.stdout

    result, commands = run(['mise global:node', 'source:Noctalia community', 'container:web'])
    assert result.returncode == 0, result.stderr
    assert 'mise global:node: old -> new' in result.stdout
    assert commands == ['mise upgrade --global node', 'podman auto-update',
                        'noctalia msg plugins update community'], commands

    result, commands = run(['source:codebase-memory-mcp'], ['source revision unknown'])
    assert result.returncode != 0 and not commands
    assert 'source revision unknown' in result.stderr
    assert 'No updates' not in result.stdout

    result, commands = run(['checkupdates:linux', 'source:claude-code-config'], fail='arch-update')
    assert result.returncode == 42 and commands == ['arch-update'], (result.stderr, commands)

    result, commands = run(['source:pi-mimir'])
    assert result.returncode == 0 and commands == ['mise run pi-mimir-sync']

    result, commands = run(['source:pi-mimir'], patcher_changed=True)
    assert result.returncode == 0, result.stderr
    assert commands == ['mise run pi-mimir-sync', 'mise run hindsight-patch'], commands

    result, commands = run(['source:pi-mimir'], patcher_changed=True, fail='mise run hindsight-patch')
    pending = home / '.local/state/dotfiles/updates/hindsight-patch.pending'
    assert result.returncode == 42 and pending.is_file()
    result, commands = run(['patch:Hindsight'])
    assert result.returncode == 0 and commands == ['mise run hindsight-patch'], result.stderr
    assert not pending.exists()

    result, commands = run(['npm:Hindsight'], fail='npx @vectorize-io/hindsight-coding-agents update')
    assert result.returncode == 42
    assert commands == ['npx @vectorize-io/hindsight-coding-agents update',
                        'mise run hindsight-patch'], commands

    result, commands = run(['source:pi-mimir', 'npm:Hindsight'])
    assert result.returncode == 0, result.stderr
    assert commands == ['mise run pi-mimir-sync', 'npx @vectorize-io/hindsight-coding-agents update',
                        'mise run hindsight-patch'], commands

    result, commands = run(['source:claude-code-config'], fail='codebase-memory-mcp daemon status')
    assert result.returncode == 0 and commands == ['mise run claude-code-config-sync']

    result, commands = run(['mise no-global:helix', 'cache:bat'])
    assert result.returncode == 0, result.stderr
    assert commands == ['mise upgrade --no-global helix', 'mise run helix-grammars',
                        'mise run bat-cache'], commands

    result, commands = run(['source:codebase-memory-mcp'], fail='mise run codebase-memory-build')
    assert result.returncode == 42 and commands == ['mise run codebase-memory-build']

    mise = shutil.which('mise')
    assert mise, 'mise is required to test the update task'
    (home / 'mise.toml').write_text('')
    (home / 'mise.linux.toml').write_text('[tasks.update]\nraw = true\nrun = '
                                          + json.dumps(config['tasks']['update']['run']) + '\n')
    log = home / 'log'
    env = {key: value for key, value in os.environ.items() if not key.startswith(('MISE_', 'XDG_'))}
    env.update(HOME=str(home), PATH=f'{scripts}:/usr/bin:/bin', LOG=str(log), FAIL='',
               PATCHER=str(patcher), PATCHER_CHANGED='0',
               MISE_CONFIG_DIR=str(home / 'config'), MISE_DATA_DIR=str(home / 'data'),
               MISE_CACHE_DIR=str(home / 'cache'), MISE_STATE_DIR=str(home / 'state'),
               MISE_SYSTEM_CONFIG_DIR=str(home / 'system'),
               MISE_GLOBAL_CONFIG_FILE=str(home / 'global.toml'),
               MISE_TRUSTED_CONFIG_PATHS=str(home),
               MISE_AUTO_ENV='true', MISE_OFFLINE='true', MISE_YES='1')
    for ids, errors, expected in (
        ([], [], []),
        (['mise global:node'], [], ['mise upgrade --global node']),
        (['mise global:node'], ['check failed'], []),
    ):
        log.write_text('')
        result = subprocess.run([mise, 'run', 'update'], cwd=home, capture_output=True, text=True,
                                env=dict(env, UPDATES=json.dumps([row(id) for id in ids]),
                                         ERRORS=json.dumps(errors)))
        assert (result.returncode == 0) == (not errors), (result.stdout, result.stderr)
        assert log.read_text().splitlines() == expected

print('update orchestration selfcheck passed')
