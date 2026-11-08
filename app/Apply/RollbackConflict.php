<?php

declare(strict_types=1);

namespace App\Apply;

use RuntimeException;

final class RollbackConflict extends RuntimeException
{
    /**
     * @param  list<string>  $conflicts
     */
    public function __construct(public readonly array $conflicts)
    {
        parent::__construct("Rollback refused, nothing was written:\n- ".implode("\n- ", $conflicts));
    }
}
