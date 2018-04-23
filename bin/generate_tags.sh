#!/bin/sh
#ctags -R --language-force=c++ --c++-kinds=+plx --fields=+iaS --extra=+q -f ~/cpp_tags /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1
ctags -R --language-force=c++ --c++-kinds=+plx --fields=+iaS --extra=+q -f ~/cpp_tags `echo | g++ -v -x c++ -E - 2>&1 |grep '^ .*/include/c++\(/[^/]*\)\?$'`
#echo | g++ -v -x c++ -E -
