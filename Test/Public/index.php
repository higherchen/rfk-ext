<?php

define('ROOT', __DIR__.'/..');

// 自动开启session
// session_start();

// 构建app，并开始处理请求
$app = include ROOT.'/bootstrap.php';
$router = include $app->getCurrentRoute();
$app->handle($router);
