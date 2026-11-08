<?php

namespace Tests;

use LaravelZero\Framework\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        config()->set('database.connections.coolify', [
            ...config('database.connections.coolify'),
            'host' => '127.0.0.1',
            'port' => getenv('COOLHOP_TEST_DB_PORT') ?: '54329',
            'database' => 'coolify',
            'username' => 'postgres',
            'password' => 'x',
        ]);
    }
}
