<?php

namespace App\Security;

use Illuminate\Encryption\Encrypter;
use Throwable;

final class Decryptor
{
    private ?Encrypter $encrypter = null;

    public function __construct(?string $appKey)
    {
        if ($appKey !== null && $appKey !== '') {
            $key = str_starts_with($appKey, 'base64:') ? base64_decode(substr($appKey, 7)) : $appKey;
            $this->encrypter = new Encrypter($key, 'aes-256-cbc');
        }
    }

    public static function fromEnvironment(): self
    {
        return new self(getenv('APP_KEY') ?: null);
    }

    public function canDecrypt(): bool
    {
        return $this->encrypter instanceof Encrypter;
    }

    public function decrypt(string $payload): ?string
    {
        if (! $this->encrypter instanceof Encrypter) {
            return null;
        }

        try {
            $value = $this->encrypter->decryptString($payload);
        } catch (Throwable) {
            return null;
        }

        return $this->unserializeString($value);
    }

    private function unserializeString(string $value): string
    {
        if (preg_match('/^s:\d+:".*";$/s', $value) !== 1) {
            return $value;
        }

        $unserialized = @unserialize($value, ['allowed_classes' => false]);

        return is_string($unserialized) ? $unserialized : $value;
    }
}
