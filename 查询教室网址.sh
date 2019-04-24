#!/bin/bash
#查询网段地址
a=254
x=0
y=0
for i in `seq $a`
  do
    ping -c 3 -i 0.2 -w 1 176.4.11.$i  &> /dev/null
  if [ $? -eq 0 ]; then
       echo "176.4.11.$i  存在" >> ./ok.txt
       let x++  
  else
       echo " 176.4.11.$i 不存在"  > /dev/null
       let y++  
  fi
  done
#echo "$x台主机存在"
#echo "$y台主机不存在"

