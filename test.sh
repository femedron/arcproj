#!/usr/bin/zsh

nasm -felf64 ./src/start.asm -o ./bin/obj/start.o
ld ./bin/obj/start.o -o ./bin/out/start
echo "" > test.res
echo "=== test1 ===" >> test.res
sed -i 's/\r$//' ./tests/V3TEST1.IN  				 # replace \r\n with \n
./bin/out/start < ./tests/V3TEST1.IN >> test.res
echo "=== test2 ===" >> test.res
sed -i 's/\r$//' ./tests/V3TEST2.IN
./bin/out/start < ./tests/V3TEST2.IN >> test.res
echo "=== test3 ===" >> test.res
sed -i 's/\r$//' ./tests/V3TEST3.IN
./bin/out/start < ./tests/V3TEST3.IN >> test.res

diff -s test.res ./tests/V3TEST.OK
