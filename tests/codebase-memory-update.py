import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib

root = Path(__file__).resolve().parents[1]
task = tomllib.loads((root / 'mise.toml').read_text())['tasks']['codebase-memory-build']
mise = shutil.which('mise')
binary = '''#!/usr/bin/python3
import json, os, sys
from pathlib import Path
generation = 'old'
path = Path(os.environ['FIXTURE_STATE'])
s = json.loads(path.read_text())
scenario = os.environ['SCENARIO']
args = sys.argv[1:]
if args == ['--version']:
    if scenario == 'bad_candidate' and generation == 'new': sys.exit(17)
    print('codebase-memory-mcp ' + generation)
elif args == ['daemon', 'status']:
    if scenario == 'wedged':
        print('daemon: not responding (endpoint held by pid 101)')
        sys.exit(1)
    if s['phase'] == 'stopping':
        s['polls'] += 1
        if s['polls'] >= 2: s['phase'] = 'absent'
        path.write_text(json.dumps(s))
    if s['phase'] == 'absent':
        print('daemon: not running')
        sys.exit(1)
    print('daemon: active (' + s['lifetime'] + ')')
    print('  pid: 101')
    print('  committed clients: ' + str(s['clients']))
    if s['phase'] == 'stopping': print('  state: stopping')
elif args == ['daemon', 'stop']:
    if scenario == 'stop_busy': s['clients'] = 1
    if s['clients']:
        path.write_text(json.dumps(s))
        print('daemon: NOT stopped — clients still use it.')
        sys.exit(1)
    s['phase'] = 'stopping'
    s['stopped'] = True
    path.write_text(json.dumps(s))
    print('daemon: stopping (pid 101)')
elif args == ['daemon', 'start']:
    s['phase'] = 'active'
    s['daemon_image'] = generation
    s['restarts'] += 1
    path.write_text(json.dumps(s))
else:
    raise AssertionError(args)
'''
with tempfile.TemporaryDirectory(prefix='codegraph-update-test-') as temporary:
    fixture = Path(temporary)
    bins = fixture / 'bin'
    bins.mkdir()
    for name in ('git', 'ps', 'systemctl'):
        command = bins / name
        command.write_text('''#!/usr/bin/python3
import json, os, sys
from pathlib import Path
s = json.loads(Path(os.environ['FIXTURE_STATE']).read_text())
name = Path(sys.argv[0]).name
if name == 'systemctl': raise AssertionError('Native daemon must not depend on systemd')
if name == 'ps':
    if s['phase'] != 'absent': print('101 codebase-memory-')
    if os.environ['SCENARIO'] == 'worker': print('202 codebase-memory-')
elif name == 'git':
    assert s['phase'] == 'absent', 'Source changed before daemon stopped'
    if 'rev-parse' in sys.argv: print('b' * 40)
    else:
        s['source_changed'] = True
        Path(os.environ['FIXTURE_STATE']).write_text(json.dumps(s))
''')
        command.chmod(0o755)
    (bins / 'mise').symlink_to(mise)
    lines = ['[tasks.codebase-memory-build]']
    lines.extend(f'{key} = {json.dumps(task[key])}' for key in ('shell', 'run'))
    (fixture / 'graph-test.toml').write_text('\n'.join(lines))
    base = {key: value for key, value in os.environ.items() if not key.startswith(('MISE_', 'XDG_'))}
    for scenario in ('busy', 'worker', 'stop_busy', 'wedged', 'idle', 'absent', 'session', 'build_fail', 'bad_candidate', 'respawn'):
        home = fixture / scenario
        source = home / 'github/DeusData/codebase-memory-mcp'
        (source / '.git').mkdir(parents=True)
        (source / 'scripts').mkdir()
        (source / 'build/c').mkdir(parents=True)
        installed = home / '.local/bin/codebase-memory-mcp'
        installed.parent.mkdir(parents=True)
        installed.write_text(binary)
        installed.chmod(0o755)
        before = hashlib.sha256(installed.read_bytes()).digest()
        candidate = source / 'candidate'
        candidate.write_text(binary.replace("generation = 'old'", "generation = 'new'"))
        build = source / 'scripts/build.sh'
        build.write_text('''#!/usr/bin/python3
import json, os, sys
from pathlib import Path
path = Path(os.environ['FIXTURE_STATE'])
s = json.loads(path.read_text())
assert s['phase'] == 'absent', 'Build started while daemon was running'
s['built'] = True
if os.environ['SCENARIO'] == 'respawn': s['phase'] = 'active'
path.write_text(json.dumps(s))
if os.environ['SCENARIO'] == 'build_fail': sys.exit(41)
output = Path('build/c/codebase-memory-mcp')
output.write_bytes(Path('candidate').read_bytes())
output.chmod(0o755)
''')
        build.chmod(0o755)
        state = home / 'daemon.json'
        state.write_text(json.dumps(dict(phase='absent' if scenario == 'absent' else 'active',
                                         lifetime='session-managed' if scenario == 'session' else 'permanent',
                                         clients=1 if scenario == 'busy' else 0, polls=0, restarts=0,
                                         stopped=False, source_changed=False, built=False, daemon_image='old')))
        env = dict(base, HOME=str(home), PATH=f'{bins}:/usr/bin:/bin', FIXTURE_STATE=str(state), SCENARIO=scenario,
                   MISE_CONFIG_DIR=str(home / 'config'), MISE_DATA_DIR=str(home / 'data'),
                   MISE_CACHE_DIR=str(home / 'cache'), MISE_STATE_DIR=str(home / 'state'),
                   MISE_SYSTEM_CONFIG_DIR=str(home / 'system'), MISE_GLOBAL_CONFIG_FILE=str(home / 'global.toml'),
                   MISE_OVERRIDE_CONFIG_FILENAMES='graph-test.toml', MISE_TRUSTED_CONFIG_PATHS=str(fixture),
                   MISE_AUTO_ENV='false', MISE_OFFLINE='true', MISE_YES='1')
        result = subprocess.run([mise, 'run', 'codebase-memory-build'], cwd=fixture, env=env, capture_output=True, text=True)
        observed = json.loads(state.read_text())
        successful = scenario in ('idle', 'absent', 'session')
        assert (result.returncode == 0) == successful, (scenario, result.stdout, result.stderr)
        if not successful:
            assert hashlib.sha256(installed.read_bytes()).digest() == before, scenario
        if scenario in ('busy', 'worker', 'stop_busy', 'wedged'):
            assert not observed['source_changed'] and not observed['built'] and not observed['stopped'], scenario
        elif successful:
            assert "generation = 'new'" in installed.read_text(), scenario
            assert observed['phase'] == ('active' if scenario == 'idle' else 'absent'), scenario
            assert observed['restarts'] == (1 if scenario == 'idle' else 0), scenario
            assert (home / '.local/state/dotfiles/updates/codebase-memory-mcp.revision').read_text().strip() == 'b' * 40
        else:
            assert observed['phase'] == 'active' and observed['daemon_image'] == 'old', scenario
print('Native daemon update refuses active use, waits for shutdown, preserves old binary on failure, and restores prior lifetime.')
