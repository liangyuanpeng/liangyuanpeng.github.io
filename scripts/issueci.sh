#/bin/sh

echo "==========================="
env
echo "==========================="

if [ $1 ];then
	echo "issueci params: \n $1"
else