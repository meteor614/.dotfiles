#!/bin/sh
ctags -R --language-force=c++ --c++-kinds=+plx --fields=+iaS --extra=+q -f ~/cpp_tags /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1
#/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1
#/usr/local/include
#/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/9.1.0/include
#/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include
#/usr/include
#/System/Library/Frameworks (framework directory)
#/Library/Frameworks (framework directory)
#echo | g++ -v -x c++ -E -
