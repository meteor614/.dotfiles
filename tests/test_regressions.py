#!/usr/bin/env python3
"""Offline checks: extract functions without running either script's entrypoint."""
import io
import os
from pathlib import Path
import re
import subprocess
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def functions(path, *names):
    source = (ROOT / path).read_text()
    return '\n'.join(
        re.search(r'^' + re.escape(name) + r'\(\) \{(?:[^\n]*\}[^\n]*$|\n.*?^\})', source, re.M | re.S)[0]
        for name in names
    ).replace('$HOME', '$TEST_HOME').replace('${HOME}', '${TEST_HOME}')


class Regressions(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='.regression-', dir=ROOT)
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name)

    def run_shell(self, script, shell='bash'):
        env = dict(os.environ, TEST_HOME=str(self.base), TMPDIR=str(self.base))
        result = subprocess.run(
            [shell, '-f', '-c', 'set -eu\n' + script] if shell == 'zsh'
            else [shell, '--noprofile', '--norc', '-c', 'set -eu\n' + script],
            env=env, text=True, capture_output=True, cwd=ROOT,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def release_functions(self):
        return functions('setup.sh', 'command_exists', 'yellow', 'red', 'ensure_dir',
                         'linux_release_arch', 'linux_release_arch_arm64',
                         'linux_release_arch_fastfetch', 'linux_release_arch_mise',
                         'linux_release_arch_amd64_arm64', 'is_elf',
                         'release_tool_version_output', 'release_tool_state',
                         'install_linux_release_tool', 'install_linux_release_tools',
                         'install_neovim_release') + '''
MODE=init DRY_RUN=0 os=linux
release_failed_tools=()
register_temp_dir() { :; }
'''

    def test_cache_age_in_both_shells(self):
        for name, days in [('fresh', 1), ('expired', 31), ('future', -1)]:
            path = self.base / name
            path.touch()
            stamp = 1900000000 - days * 86400
            os.utime(path, (stamp, stamp))
        script = functions('.config/shell/common.sh', '_dotfiles_term_cache_fresh') + '''
date() { echo 1900000000; }
_dotfiles_term_cache_fresh "$TEST_HOME/fresh"
! _dotfiles_term_cache_fresh "$TEST_HOME/expired"
! _dotfiles_term_cache_fresh "$TEST_HOME/future"
! _dotfiles_term_cache_fresh "$TEST_HOME/missing"
# Simulate BSD stat after the GNU invocation fails.
stat() { [ "$1" = '-f' ] || return 1; echo 1899913600; }
_dotfiles_term_cache_fresh "$TEST_HOME/fresh"
'''
        for shell in ('bash', 'zsh'):
            with self.subTest(shell=shell):
                self.run_shell(script, shell)

    def test_zcompile_only_when_needed(self):
        source = functions('.config/shell/common.sh', '_dotfiles_zcompile_startup')
        path = self.base / '.zshrc'
        path.write_text('export EXAMPLE=1\n')
        self.run_shell('''_DOTFILES_SHELL=zsh
''' + source + '''
_dotfiles_zcompile_startup
[[ -f "$TEST_HOME/.zshrc.zwc" ]]
''' + source + '''
# If the cache is fresh the compiler must never be invoked.
zcompile() { print 'unexpected compilation' >&2; exit 99; }
_dotfiles_zcompile_startup
''', 'zsh')
        os.utime(path, (1900000000, 1900000000))
        self.run_shell('_DOTFILES_SHELL=zsh\n' + source + '''
called=0
zcompile() { called=1; }
_dotfiles_zcompile_startup
[[ "$called" = 1 ]]
''', 'zsh')

    def test_brew_failure_does_not_skip_apt(self):
        self.run_shell(functions('bin/update_all.sh', 'update_pkg_manager') + '''
have_cmd() { [ "$1" = brew ] || [ "$1" = apt ]; }
log() { :; }
brew() { echo "brew $*" >> "$TEST_HOME/calls"; return 1; }
sudo() { echo "$*" >> "$TEST_HOME/calls"; }
if update_pkg_manager; then exit 90; fi
grep -q '^apt update$' "$TEST_HOME/calls"
grep -q '^apt autoremove -y$' "$TEST_HOME/calls"
''')

    def test_release_failures_are_collected_and_loop_continues(self):
        self.run_shell(self.release_functions() + '''
linux_release_tools=('bad|repo|url|bin' 'good|repo|url|bin')
release_tools_have_work() { return 0; }
github_reachable() { return 0; }
install_linux_release_tool() {
    echo "$1" >> "$TEST_HOME/calls"
    [ "$1" = good ]
}
install_linux_release_tools
[ "${release_failed_tools[*]}" = bad ]
[ "$(tail -1 "$TEST_HOME/calls")" = good ]
''')

    def test_release_network_failure_is_recorded(self):
        self.run_shell(self.release_functions() + '''
release_tools_have_work() { return 0; }
github_reachable() { return 1; }
install_linux_release_tools
[ "${#release_failed_tools[@]}" -eq 1 ]
''')

    def test_final_failure_status_and_summary(self):
        source = (ROOT / 'setup.sh').read_text()
        footer = source[source.index('setup_failed=0\n'):]
        for background_failed in (False, True):
            script = functions('setup.sh', 'red') + '''
release_failed_tools=(fake)
MODE=init CHECK_FAILED=0
''' + ('wait_for_background_jobs() { return 1; }\n'
       if background_failed else 'wait_for_background_jobs() { return 0; }\n') + footer
            result = subprocess.run(['bash', '--noprofile', '--norc', '-c', script],
                                    text=True, capture_output=True)
            self.assertEqual(result.returncode, 1)
            self.assertIn('Failed release tools: fake', result.stdout)

    def test_release_lookup_and_download_failure(self):
        self.run_shell(self.release_functions() + '''
gh_latest_tag() { return 1; }
if install_linux_release_tool fake repo url fake; then exit 90; fi
gh_latest_tag() { echo v1.0.0; }
gh_dl() { return 1; }
if install_linux_release_tool fake repo url fake; then exit 91; fi
''')

    def test_bad_checksum_preserves_installed_binary(self):
        (self.base / 'bin').mkdir()
        installed = self.base / 'bin/fake'
        installed.write_text('#!/bin/sh\necho fake 0.1.0\n')
        installed.chmod(0o755)
        self.run_shell(self.release_functions() + '''
DOTFILES_RELEASES_REFRESH=1
release_tool_state() { return 1; }
gh_latest_tag() { echo v1.0.0; }
checksum_url_for() { echo checksum; }
verify_sha256() { return 1; }
# A syntactically valid digest whose verification fails on both downloads.
gh_dl() { printf '%064d\n' 0 > "$2"; }
if install_linux_release_tool fake repo pkg.tar.gz fake; then exit 90; fi
[ "$("$TEST_HOME/bin/fake")" = 'fake 0.1.0' ]
''')

    def test_neovim_refresh_and_install_source_boundary(self):
        arch = {'x86_64': 'x86_64', 'aarch64': 'arm64'}[os.uname().machine]
        archive = self.base / 'nvim.tar.gz'
        with tarfile.open(archive, 'w:gz') as tar:
            data = b'#!/bin/sh\necho NVIM v1.0.0\n'
            entry = tarfile.TarInfo(f'nvim-linux-{arch}/bin/nvim')
            entry.mode, entry.size = 0o755, len(data)
            tar.addfile(entry, io.BytesIO(data))
        self.run_shell(self.release_functions() + '''
DOTFILES_RELEASES_REFRESH=1
# Simulate an external nvim: do not even query releases.
command_exists() { [ "$1" = nvim ] || command -v "$1" >/dev/null 2>&1; }
gh_latest_tag() { exit 90; }
install_neovim_release
# Install a managed old runtime and refresh through its exact symlink.
mkdir -p "$TEST_HOME/.local/opt/nvim/bin" "$TEST_HOME/.local/bin"
printf '#!/bin/sh\\necho NVIM v0.9.0\\n' > "$TEST_HOME/.local/opt/nvim/bin/nvim"
chmod +x "$TEST_HOME/.local/opt/nvim/bin/nvim"
ln -s "$TEST_HOME/.local/opt/nvim/bin/nvim" "$TEST_HOME/.local/bin/nvim"
gh_latest_tag() { echo v1.0.0; }
gh_dl() { cp "$TEST_HOME/nvim.tar.gz" "$2"; }
install_neovim_release
[ "$("$TEST_HOME/.local/bin/nvim" --version)" = 'NVIM v1.0.0' ]
# Current version and install-only mode must not download anything.
gh_dl() { exit 91; }
install_neovim_release
DOTFILES_RELEASES_REFRESH=0
gh_latest_tag() { exit 92; }
install_neovim_release
''')

    def test_neovim_failed_download_preserves_old_runtime(self):
        self.run_shell(self.release_functions() + '''
DOTFILES_RELEASES_REFRESH=1
mkdir -p "$TEST_HOME/.local/opt/nvim/bin" "$TEST_HOME/.local/bin"
printf '#!/bin/sh\\necho NVIM v0.9.0\\n' > "$TEST_HOME/.local/opt/nvim/bin/nvim"
chmod +x "$TEST_HOME/.local/opt/nvim/bin/nvim"
ln -s "$TEST_HOME/.local/opt/nvim/bin/nvim" "$TEST_HOME/.local/bin/nvim"
gh_latest_tag() { echo v1.0.0; }
gh_dl() { return 1; }
if install_neovim_release; then exit 90; fi
[ "$("$TEST_HOME/.local/bin/nvim")" = 'NVIM v0.9.0' ]
''')


if __name__ == '__main__':
    unittest.main()
