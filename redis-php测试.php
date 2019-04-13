<?php
$redis = new redis();
$redis->connect('192.168.4.50',6350);
$redis->auth('1234');
$redis->set('redistest','888888888888888888');
echo $redis->get('redistest');
?>
