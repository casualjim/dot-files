import os
import pathlib
import subprocess
import sys
import tempfile

script = pathlib.Path(__file__).resolve().parents[1] / '.local/bin/dotfiles-update-launch'
with tempfile.TemporaryDirectory() as directory:
    root = pathlib.Path(directory)
    ghostty = root / 'ghostty'
    ghostty.write_text('''#!/usr/bin/env python3
import os, subprocess, sys
if os.environ.get('CLOSE_EARLY'):
    sys.exit(0)
args = sys.argv[sys.argv.index('-e') + 1:]
subprocess.run(args, input='\\n', text=True)
''')
    mise = root / 'mise'
    mise.write_text('''#!/usr/bin/env python3
import os, sys
assert sys.argv[1:] == ['-C', os.environ['REPO'], 'run', 'update']
sys.exit(int(os.environ['UPDATE_EXIT']))
''')
    ghostty.chmod(0o755)
    mise.chmod(0o755)
    env = dict(os.environ, PATH=f'{root}:{os.environ["PATH"]}', REPO=str(script.parents[2]))
    for code in (0, 7):
        result = subprocess.run([sys.executable, str(script)], env=dict(env, UPDATE_EXIT=str(code)), capture_output=True, text=True)
        assert result.returncode == code, result
    result = subprocess.run([sys.executable, str(script)], env=dict(env, CLOSE_EARLY='1'), capture_output=True, text=True)
    assert result.returncode == 1 and 'before reporting completion' in result.stderr, result
print('Terminal success, failure, and early-close checks passed.')
