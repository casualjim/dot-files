import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib

root = Path(__file__).resolve().parents[1]
tasks = tomllib.loads((root / 'mise.toml').read_text())['tasks']
patcher = Path(os.environ.get('PI_MIMIR_ROOT', Path.home() / 'github/casualjim/pi-mimir')) / 'packages/pi-hindsight/patch-dist.mjs'
patch = patcher.read_text()
mise = shutil.which('mise')
node = subprocess.check_output([mise, 'which', 'node'], text=True).strip()
stock = '''function applyTemplate(template, resolvers, what) {
  return template.replace(/\\{([a-zA-Z]+)\\}/g, (_, name) => resolvers[name] ? resolvers[name]() : "unknown");
}
console.log(applyTemplate("omp-{gitProjectLower}", {gitProject: () => "DemoProject"}, "bank"));
'''
with tempfile.TemporaryDirectory(prefix='hindsight-update-test-') as temporary:
    fixture = Path(temporary)
    home = fixture / 'home'
    source = home / 'github/casualjim/pi-mimir'
    (source / '.git').mkdir(parents=True)
    local_patch = source / 'packages/pi-hindsight/patch-dist.mjs'
    local_patch.parent.mkdir(parents=True)
    local_patch.write_text(patch)
    bins = fixture / 'bin'
    bins.mkdir()
    (bins / 'node').symlink_to(node)
    (bins / 'mise').symlink_to(mise)
    git = bins / 'git'
    git.write_text('''#!/bin/bash
if [[ $* == *pull* && ${SYNC_FAIL:-0} == 1 ]]; then exit 23; fi
if [[ $* == *rev-parse* ]]; then printf '%040d\\n' 1; fi
''')
    git.chmod(0o755)
    npx = bins / 'npx'
    npx.write_text('''#!/usr/bin/python3
import os
from pathlib import Path
import sys
assert sys.argv[1:] in (["@vectorize-io/hindsight-coding-agents", "update"], ["@vectorize-io/hindsight-coding-agents", "install", "all"])
dist = Path.home() / '.hindsight/coding-agents/dist'
dist.mkdir(parents=True, exist_ok=True)
(dist / 'bank.js').write_text(Path(os.environ['STOCK']).read_text())
sys.exit(int(os.environ['UPDATE_EXIT']))
''')
    npx.chmod(0o755)
    (fixture / 'stock.cjs').write_text(stock)
    config = []
    for name in ('hindsight-install', 'hindsight-update', 'hindsight-patch', 'pi-mimir-sync'):
        config.append(f'[tasks.{name}]')
        for key in ('shell', 'run'):
            if key in tasks[name]:
                config.append(f'{key} = {json.dumps(tasks[name][key])}')
    (fixture / 'hindsight-test.toml').write_text('\n'.join(config))
    env = {key: value for key, value in os.environ.items() if not key.startswith(('MISE_', 'XDG_'))}
    env.update(HOME=str(home), PATH=f'{bins}:/usr/bin:/bin', STOCK=str(fixture / 'stock.cjs'),
               MISE_CONFIG_DIR=str(fixture / 'config'), MISE_DATA_DIR=str(fixture / 'data'),
               MISE_CACHE_DIR=str(fixture / 'cache'), MISE_STATE_DIR=str(fixture / 'state'),
               MISE_SYSTEM_CONFIG_DIR=str(fixture / 'system'), MISE_GLOBAL_CONFIG_FILE=str(fixture / 'global.toml'),
               MISE_OVERRIDE_CONFIG_FILENAMES='hindsight-test.toml', MISE_TRUSTED_CONFIG_PATHS=str(fixture),
               MISE_AUTO_ENV='false', MISE_OFFLINE='true', MISE_YES='1')
    for task in ('hindsight-install', 'hindsight-update'):
        for upstream_status in ('0', '42'):
            local_patch.write_text(patch)
            result = subprocess.run([mise, 'run', task], cwd=fixture,
                                    env=dict(env, UPDATE_EXIT=upstream_status), capture_output=True, text=True)
            assert (result.returncode == 0) == (upstream_status == '0'), result.stderr
            bank = home / '.hindsight/coding-agents/dist/bank.js'
            resolved = subprocess.check_output([node, str(bank)], env=env, text=True).strip()
            assert resolved == 'omp-demoproject', (task, upstream_status, resolved, result.stderr)
        local_patch.write_text('process.exit(9);\n')
        result = subprocess.run([mise, 'run', task], cwd=fixture, env=dict(env, UPDATE_EXIT='0'), capture_output=True, text=True)
        assert result.returncode != 0, 'Patch failure was reported as success'
        local_patch.write_text(patch)
        bank.write_text('console.log("previous-compatible-bank");\n')
        result = subprocess.run([mise, 'run', task], cwd=fixture,
                                env=dict(env, UPDATE_EXIT='0', SYNC_FAIL='1'), capture_output=True, text=True)
        assert result.returncode != 0, 'Source synchronization failure was ignored'
        assert subprocess.check_output([node, str(bank)], env=env, text=True).strip() == 'previous-compatible-bank'
print('Hindsight install/update preserve patched bank resolution after failed staging and reject patch/sync failures.')
