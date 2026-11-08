<?php

use Tests\Support\Database;
use Tests\TestCase;

uses(TestCase::class)->in('Feature');

uses()->beforeEach(fn () => Database::reset())->in('Feature');
