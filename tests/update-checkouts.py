import json
import os
from pathlib import Path
import runpy
import shutil
import subprocess
import tempfile
import tomllib

root = Path(__file__).resolve().parents[1]
mise = shutil.which('mise')
assert mise, 'mise is required for the checkout update test'
task = tomllib.loads((root / 'mise.toml').read_text())['tasks']['pi-mimir-sync']

with tempfile.TemporaryDirectory(prefix='checkout-update-test-') as directory:
    fixture = Path(directory)
    home = fixture / 'home'
    repo = home / 'github/casualjim/pi-mimir'
    upstream = fixture / 'upstream'
    repo.mkdir(parents=True)
    upstream.mkdir()
    env = {key: value for key, value in os.environ.items() if not key.startswith(('MISE_', 'XDG_'))}
    env.update(HOME=str(home), PATH='/usr/bin:/bin', GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL='/dev/null',
               GIT_AUTHOR_NAME='Fixture', GIT_AUTHOR_EMAIL='fixture@example.test',
               GIT_COMMITTER_NAME='Fixture', GIT_COMMITTER_EMAIL='fixture@example.test',
               MISE_CONFIG_DIR=str(fixture / 'config'), MISE_DATA_DIR=str(fixture / 'data'),
               MISE_CACHE_DIR=str(fixture / 'cache'), MISE_STATE_DIR=str(fixture / 'state'),
               MISE_SYSTEM_CONFIG_DIR=str(fixture / 'system'), MISE_GLOBAL_CONFIG_FILE=str(fixture / 'global.toml'),
               MISE_OVERRIDE_CONFIG_FILENAMES='checkout-test.toml', MISE_TRUSTED_CONFIG_PATHS=str(fixture),
               MISE_AUTO_ENV='false', MISE_OFFLINE='true', MISE_YES='1')
    os.environ.clear()
    os.environ.update(env)
    checkout = runpy.run_path(str(root / '.local/bin/dotfiles-update-check'))['checkout']

    def git(path, *args):
        return subprocess.check_output(['git', '-C', str(path), *args], env=env, text=True,
                                       stderr=subprocess.PIPE).strip()

    git(upstream, 'init', '--initial-branch=main')
    git(upstream, 'commit', '--allow-empty', '-m', 'base')
    base = git(upstream, 'rev-parse', 'HEAD')
    git(upstream, 'branch', 'release')
    git(repo, 'init', '--initial-branch=main')
    git(repo, 'remote', 'add', 'origin', str(upstream))
    git(repo, 'fetch', 'origin')
    git(repo, 'checkout', '-b', 'main', '--track', 'origin/main')
    assert checkout('pi-mimir', repo) == []

    git(repo, 'commit', '--allow-empty', '-m', 'unpublished local change')
    ahead = git(repo, 'rev-parse', 'HEAD')
    assert checkout('pi-mimir', repo) == []
    assert git(repo, 'rev-parse', 'HEAD') == ahead

    git(repo, 'update-ref', 'refs/heads/main', base, ahead)
    git(repo, 'config', 'branch.main.merge', 'refs/heads/release')
    git(upstream, 'commit', '--allow-empty', '-m', 'new upstream change')
    target = git(upstream, 'rev-parse', 'HEAD')
    assert checkout('pi-mimir', repo) == [], 'Default remote HEAD is not the tracked branch'

    git(repo, 'config', 'branch.main.merge', 'refs/heads/main')
    rows = checkout('pi-mimir', repo)
    assert len(rows) == 1 and rows[0]['from_version'] == base and rows[0]['to_version'] == target
    git(repo, 'fetch', 'origin')
    assert checkout('pi-mimir', repo) == rows

    config = '[tasks.pi-mimir-sync]\n'
    config += '\n'.join(f'{key} = {json.dumps(task[key])}' for key in ('shell', 'run'))
    (fixture / 'checkout-test.toml').write_text(config)
    result = subprocess.run([mise, 'run', 'pi-mimir-sync'], cwd=fixture, env=env,
                            text=True, capture_output=True)
    assert result.returncode == 0, (result.stdout, result.stderr)
    assert git(repo, 'rev-parse', 'HEAD') == target
    assert checkout('pi-mimir', repo) == []

    git(repo, 'commit', '--allow-empty', '-m', 'local divergence')
    local = git(repo, 'rev-parse', 'HEAD')
    git(upstream, 'commit', '--allow-empty', '-m', 'remote divergence')
    git(repo, 'fetch', 'origin')
    try:
        checkout('pi-mimir', repo)
    except ValueError as error:
        assert 'diverged' in str(error)
    else:
        raise AssertionError('Divergence was advertised as a fast-forward update')
    result = subprocess.run([mise, 'run', 'pi-mimir-sync'], cwd=fixture, env=env,
                            text=True, capture_output=True)
    assert result.returncode != 0 and git(repo, 'rev-parse', 'HEAD') == local

    git(repo, 'config', '--unset', 'branch.main.merge')
    try:
        checkout('pi-mimir', repo)
    except ValueError as error:
        assert 'no tracked upstream' in str(error)
    else:
        raise AssertionError('Missing tracking configuration was silently replaced by remote HEAD')

print('Checkout detection handles equal, ahead, behind, tracked branches and divergence; real mise sync clears only completed updates.')
