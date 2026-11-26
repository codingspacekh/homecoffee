<?php

namespace App\Models\Concerns;

/**
 * Text fields stored as {"en": "...", "km": "..."}. English is required,
 * Khmer is optional and falls back to English.
 */
trait HasTranslatedFields
{
    public const LANGUAGES = ['en', 'km'];

    public function translated(string $field, string $language = 'en'): ?string
    {
        $value = $this->{$field} ?? [];

        return filled($value[$language] ?? null) ? $value[$language] : ($value['en'] ?? null);
    }

    /**
     * The extra languages in the app's format: {"km": {"name": "..."}}.
     *
     * @param  list<string>  $fields
     * @return array<string, array<string, string>>
     */
    protected function translationsFor(array $fields): array
    {
        $translations = [];
        foreach ($fields as $field) {
            $value = $this->{$field}['km'] ?? null;
            if (filled($value)) {
                $translations['km'][$field] = $value;
            }
        }

        return $translations;
    }
}
