<?php

declare(strict_types=1);

use Tests\Support\Database;
use Tests\TestCase;

uses(TestCase::class)->in('Feature');

uses()->beforeEach(fn () => Database::reset())->in('Feature');
