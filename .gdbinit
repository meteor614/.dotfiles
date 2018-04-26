set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style auto
set print sevenbit-strings off
set verbose off
set history filename ~/.gdb_history
set history save

# load gdb-dashboard, install use command: git clone https://github.com/cyrus-and/gdb-dashboard
so ~/gdb-dashboard/.gdbinit
dashboard -layout source assembly !expressions !history memory !registers !stack !threads
dashboard -style syntax_highlighting 'monokai'
# 1. start GDB in one terminal;
# 2. open another terminal (e.g. tmux pane) and get its TTY with the tty command (e.g. /dev/ttys001, the name may be different for a variety of reasons);
# 3. issue the command dashboard -output /dev/ttys001 to redirect the dashboard output to the newly created terminal;
# 4. debug as usual.
# auto load
shell echo `tmux list-panes -F '#{pane_active} #{pane_tty} #{pane_current_command}'|awk 'BEGIN{TTY=-1} {if ($3 ~ /.*sh/ && $1==0 && TTY==-1) {TTY=$2}} END {if(TTY!=-1){print "dashboard -output "TTY}}'` > /tmp/tmp.gdb.dashboard.xxx
source /tmp/tmp.gdb.dashboaord.xxx
shell rm /tmp/tmp.gdb.dashboaord.xxx

# load wbl printers
so ~/wbl/gdb/printers.py
