import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
script = root / '.local/bin/dotfiles-update-check'
with tempfile.TemporaryDirectory() as temp:
    home = Path(temp)
    bins = home / 'bin'
    bins.mkdir()
    stub = bins / 'stub'
    stub.write_text(f'''#!{sys.executable}
import json, os, sys
name = os.path.basename(sys.argv[0])
args = sys.argv[1:]
if name == 'checkupdates':
    if os.environ.get('FAIL_CHECK'):
        print('database unavailable', file=sys.stderr)
        sys.exit(1)
    if os.environ.get('CHANGED'): print('linux 1.0 -> 2.0')
elif name == 'paru':
    if os.environ.get('CHANGED'): print('aur-tool 3 -> 4')
elif name == 'mise':
    if args[0] == '--version': print('2026.1.0 linux-x64')
    elif args[0] == 'settings':
        print(json.dumps({{'self_update': {{'minimum_release_age': os.environ.get('AGE', '24h')}}}}))
    elif args[0] == 'upgrade':
        if os.environ.get('MISE_ERROR'):
            print('resolution failed', file=sys.stderr)
            sys.exit(2)
        if os.environ.get('MISE_OUTDATED'):
            print('Would install node@20.1')
            sys.exit(1)
    else: print(json.dumps({{'node': {{'current': '20.0', 'latest': '99.0'}}}}))
elif name == 'git':
    if args[0] == 'ls-remote': print(('b' if os.environ.get('CHANGED') else 'a') * 40 + '\\tHEAD')
    elif args[0] == '-C':
        if args[2] == 'symbolic-ref': print('refs/heads/main')
        elif args[2] == 'for-each-ref': print('origin\\trefs/heads/main')
        elif args[2] == 'remote': print('https://example.test/pi-mimir')
        elif args[2:5] == ['rev-parse', '--verify', '--quiet']: print(args[-1].split('^')[0])
        else: print(('c' if 'grammars/sources' in args[1] and os.environ.get('GRAMMAR_CHANGED') else 'a') * 40)
    else: sys.exit(1)
elif name == 'bat':
    print(os.path.join(os.environ['HOME'], '.cache/bat'))
elif name == 'noctalia':
    if os.environ.get('CHANGED'): print('community git https://example.test/plugins')
elif name == 'podman':
    if args[0] == 'auto-update':
        print(json.dumps([{{'Policy': 'registry', 'Updated': 'pending', 'Image': 'example.test/app:latest', 'ContainerName': 'app'}}] if os.environ.get('CHANGED') else []))
    else:
        print(json.dumps([{{'RepoDigests': ['example.test/app@sha256:old']}}]))
else: sys.exit(1)
''')
    stub.chmod(0o755)
    for name in ('checkupdates', 'paru', 'mise', 'git', 'noctalia', 'podman', 'bat'):
        (bins / name).symlink_to(stub)
    (home / 'sitecustomize.py').write_text('''import io, json, os, urllib.request
class Response(io.BytesIO):
    def __init__(self, data):
        super().__init__(data if isinstance(data, bytes) else json.dumps(data).encode())
        self.headers = {}
    def __enter__(self): return self
    def __exit__(self, *args): self.close()
def open_url(request, timeout=None):
    if 'registry.npmjs.org' in request.full_url: return Response({'version': '2.0' if os.environ.get('CHANGED') else '1.0'})
    if 'mise.jdx.dev/releases.tsv' in request.full_url:
        return Response(b'2026.1.0 1\\n2026.2.0 4102444800\\n' if not os.environ.get('OLD_RELEASE') else b'2026.1.0 1\\n2026.2.0 2\\n')
    if 'example.test' in request.full_url:
        response = Response({})
        response.headers['Docker-Content-Digest'] = 'sha256:new'
        return response
    raise AssertionError(request.full_url)
urllib.request.urlopen = open_url
''')
    state = home / 'state/dotfiles/updates'
    state.mkdir(parents=True)
    for name in ('pi-mimir', 'claude-code-config', 'codebase-memory-mcp', 'docker-credential-gopass'):
        (state / (name + '.revision')).write_text('a' * 40 + '\n')
    cargo = home / '.local/.crates2.json'
    cargo.parent.mkdir(parents=True)
    cargo.write_text(json.dumps({'installs': {'omarchy-launch-screensaver 1 (git+https://github.com/casualjim/omarchy-screensaver?branch=niri-screensaver#' + 'a' * 40 + ')': {}}}))
    package = home / '.hindsight/coding-agents/package.json'
    package.parent.mkdir(parents=True)
    package.write_text('{"version":"1.0"}')
    helix = home / '.config/helix'
    grammar = helix / 'runtime/grammars'
    src = grammar / 'sources/gotmpl/src'
    src.mkdir(parents=True)
    (helix / 'languages.toml').write_text('[[grammar]]\nname = "gotmpl"\nsource = { git = "https://example.test/g", rev = "' + 'a' * 40 + '" }\n')
    (src / 'parser.c').write_text('parser')
    (grammar / 'gotmpl.so').write_text('library')
    themes = home / '.config/bat/themes'
    themes.mkdir(parents=True)
    (themes / 'theme.tmTheme').write_text('theme')
    cache = home / '.cache/bat'
    cache.mkdir(parents=True)
    for name in ('themes.bin', 'syntaxes.bin'):
        (cache / name).write_text('cache')
    for path in (grammar / 'gotmpl.so', cache / 'themes.bin', cache / 'syntaxes.bin'):
        os.utime(path, (2000000000, 2000000000))
    env = dict(os.environ, HOME=str(home), XDG_STATE_HOME=str(home / 'state'),
               XDG_CONFIG_HOME=str(home / '.config'), XDG_CACHE_HOME=str(home / '.cache'),
               PATH=str(bins), PYTHONPATH=str(home))
    def run(**extra):
        result = subprocess.run([sys.executable, str(script)], env={**env, **extra}, text=True, capture_output=True, timeout=30, check=True)
        return json.loads(result.stdout), result.stderr
    data, stderr = run()
    assert data['updates'] == [] and not stderr
    pending = state / 'hindsight-patch.pending'
    pending.touch()
    data, stderr = run()
    assert [row['id'] for row in data['updates']] == ['patch:Hindsight'] and not stderr
    pending.unlink()
    data, stderr = run(CHANGED='1', MISE_OUTDATED='1', OLD_RELEASE='1')
    rows = {row['id']: row for row in data['updates']}
    assert rows['checkupdates:linux']['from_version'] == '1.0'
    assert rows['paru:aur-tool']['to_version'] == '4'
    assert rows['mise global:node']['to_version'] == '20.1'
    assert rows['mise self:mise']['to_version'] == '2026.2.0'
    assert rows['source:pi-mimir']['from_version'] == 'a' * 40
    assert rows['source:pi-mimir']['to_version'] == 'b' * 40
    assert rows['source:Noctalia community']['from_version'] == 'a' * 40
    assert rows['source:screensaver']['from_version'] == 'a' * 40
    assert rows['npm:Hindsight']['to_version'] == '2.0'
    assert rows['container:app']['from_version'] == 'sha256:old'
    assert rows['container:app']['to_version'] == 'sha256:new'
    data, stderr = run(FAIL_CHECK='1', CHANGED='1')
    assert 'database unavailable' in data['info'] and 'database unavailable' in stderr
    assert any(row['name'] == 'aur-tool' for row in data['updates'])
    assert all(row['name'] != 'linux' for row in data['updates'])
    data, stderr = run(MISE_ERROR='1')
    assert 'resolution failed' in data['info'] and stderr
    data, _ = run(GRAMMAR_CHANGED='1')
    assert [row['id'] for row in data['updates']] == ['grammar:helix']
    (grammar / 'gotmpl.so').unlink()
    data, _ = run()
    assert [row['id'] for row in data['updates']] == ['grammar:helix']
    (grammar / 'gotmpl.so').write_text('library')
    os.utime(grammar / 'gotmpl.so', (2000000000, 2000000000))
    os.utime(src / 'parser.c', (2000000001, 2000000001))
    data, _ = run()
    assert [row['id'] for row in data['updates']] == ['grammar:helix']
    os.utime(src / 'parser.c', (1000000000, 1000000000))
    (cache / 'themes.bin').unlink()
    data, _ = run()
    assert [row['id'] for row in data['updates']] == ['cache:bat']
    (cache / 'themes.bin').write_text('cache')
    os.utime(cache / 'themes.bin', (1000000000, 1000000000))
    data, _ = run()
    assert [row['id'] for row in data['updates']] == ['cache:bat']
    (state / 'codebase-memory-mcp.revision').unlink()
    data, stderr = run()
    assert 'installed revision unknown' in data['info'] and stderr
print('update detector selfcheck passed')
