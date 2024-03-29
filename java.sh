#!/usr/bin/zsh

echo "" > javatest.res

###

echo "=== test1 ===" >> javatest.res
sed -i 's/\r$//' ./tests/V3TEST1.IN  				 # replace \r\n with \n
java -cp ./Javva/untitled/out/production/untitled Main ./tests/V3TEST1.IN >> javatest.res

echo "=== test2 ===" >> javatest.res
sed -i 's/\r$//' ./tests/V3TEST2.IN
java -cp ./Javva/untitled/out/production/untitled Main ./tests/V3TEST2.IN >> javatest.res

echo "=== test3 ===" >> javatest.res
sed -i 's/\r$//' ./tests/V3TEST3.IN
java -cp ./Javva/untitled/out/production/untitled Main ./tests/V3TEST3.IN >> javatest.res

###

sed -i 's/\r$//' ./tests/V3TEST.OK
diff -s javatest.res ./tests/V3TEST.OK

