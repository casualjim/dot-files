from pathlib import Path
import runpy
from unittest.mock import patch

root = Path(__file__).resolve().parents[1]
modules = {name: runpy.run_path(str(root / '.local/bin' / name)) for name in
           ('dotfiles-update', 'dotfiles-update-check', 'dotfiles-update-launch')}
with patch('sys.platform', 'darwin'), patch('subprocess.run', side_effect=AssertionError('Non-Linux command executed')):
    assert modules['dotfiles-update']['main']() == 1
    assert modules['dotfiles-update-launch']['main']() == 1
    updates, errors = modules['dotfiles-update-check']['collect_updates']()
    assert not updates and errors
print('All updater entrypoints reject non-Linux before external commands.')
