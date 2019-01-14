#!/bin/fish
if [ (id -u) = 0 ];
	make -B;
	./iCEburn.py -ew flash.bin;
else
	echo User must be root to flash;
end

