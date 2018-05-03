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
shell echo 'so ~/gdb-dashboard/.gdbinit\n' \
          'dashboard -layout source assembly !expressions !history memory !registers !stack !threads\n' \
          'dashboard -style syntax_highlighting "monokai"' > /tmp/tmp.gdbinit.xxx
# auto output with first avabliable tmux pane's tty
shell echo `tmux list-panes -F '#{pane_active} #{pane_tty} #{pane_current_command}'|awk 'BEGIN{TTY=-1} {if ($3 ~ /.*sh/ && $1==0 && TTY==-1) {TTY=$2}} END {if(TTY!=-1){print "dashboard -output "TTY}}'` >> /tmp/tmp.gdbinit.xxx
shell test -e ~/gdb-dashboard/.gdbinit || echo > /tmp/tmp.gdbinit.xxx

# load wbl printers if file exist
shell test -e ~/wbl/gdb/printers.py && echo 'so ~/wbl/gdb/printers.py' >> /tmp/tmp.gdbinit.xxx

source /tmp/tmp.gdbinit.xxx
#shell rm /tmp/tmp.gdbinit.xxx

