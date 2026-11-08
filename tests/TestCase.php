<?php

namespace Tests;

use LaravelZero\Framework\Testing\TestCase as BaseTestCase;
use PDO;
use Tests\Support\Database;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->app->instance(PDO::class, Database::pdo());
    }
}
