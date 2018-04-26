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

# load wbl printers
so ~/wbl/gdb/printers.py
