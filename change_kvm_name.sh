#!/bin/bash
#修改虚拟机名称
#by dr
read -p "请输入源主机名：" src_name_dr
read -p "请输入修改后的主机名" dest_name_dr
virsh dumpxml $src_name_dr > /tmp/$dest_name_dr
sed -i "s#<name>${src_name_dr}</name>#<name>${dest_name_dr}</name>#g" /tmp/$dest_name_dr
virsh undefine $src_name_dr
virsh define /tmp/$dest_name_dr
rm -rf /tmp/$dest_name_dr
