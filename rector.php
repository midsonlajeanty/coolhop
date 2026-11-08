<?php

use Rector\Config\RectorConfig;

return RectorConfig::configure()
    ->withPaths([__DIR__.'/app', __DIR__.'/tests'])
    ->withPhpSets(php84: true)
    ->withPreparedSets(deadCode: true, codeQuality: true, typeDeclarations: true, earlyReturn: true);
