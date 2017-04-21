<?php

$router = new \Raichu\Routing\Router();

// init the router
$router->prefix('/api/archive', 'archive');

// /api/archive/hello
$router->match(
    '/hello',
    function () {
        echo 'Hello! Now you are in the archive module!';
    }
)->method(['get']);

return $router;
