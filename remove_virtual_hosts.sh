#!/bin/bash
#删除虚拟机及其前端文件
#by dr
read -p "请输入源主机名：" remove_name_dr
dest_name_dr=${remove_name_dr}.xml
virsh dumpxml $remove_name_dr > /tmp/$dest_name_dr
remove_name_xml=`awk -F\' '/<source file=/{print $2}'  /tmp/$dest_name_dr`
virsh undefine $remove_name_dr
rm -rf $remove_name_xml
rm -rf /tmp/$dest_name_dr

