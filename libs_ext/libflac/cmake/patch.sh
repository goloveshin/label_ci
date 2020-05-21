#!/bin/bash

for file in `find . -type f -name '*.vcxproj'`; do sed -i -e 's@MultiThreaded<@MultiThreadedDLL<@g' -e 's@MultiThreadedDebug<@MultiThreadedDebugDLL<@g' $file; done
#for file in `find . -type f -name '*.vcxproj'`; do echo $file; done
