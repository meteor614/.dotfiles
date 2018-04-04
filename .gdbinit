set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style auto
set print sevenbit-strings off

python
import sys
sys.path.insert(0, '~/wbl/gdb')
gdb.printing.register_pretty_printer(gdb.current_objfile(), build_pretty_printer())
end
