<?php

/* 构造app对象，设置项目根目录 */
$app = new \Raichu\Foundation\App(__DIR__);

/* 模块分发设置 */
$app->dispatch('/api/archive', 'archive');     // 请求前缀是/api/v4/auth，请求会分发到Auth模块

return $app;
