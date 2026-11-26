<?php

namespace App\Domain;

/** A group of choices such as Size. The first choice is the default. */
final readonly class OptionGroup
{
    /** @param  list<Choice>  $choices */
    public function __construct(
        public string $name,
        public array $choices,
    ) {}

    /** @param  array{name: string, choices: list<array<string, mixed>>}  $data */
    public static function fromArray(array $data): self
    {
        return new self($data['name'], array_map(Choice::fromArray(...), $data['choices']));
    }

    public function default(): Choice
    {
        return $this->choices[0];
    }

    public function find(?string $label): ?Choice
    {
        foreach ($this->choices as $choice) {
            if ($choice->label === $label) {
                return $choice;
            }
        }

        return null;
    }
}
