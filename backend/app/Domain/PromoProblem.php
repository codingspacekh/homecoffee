<?php

namespace App\Domain;

enum PromoProblem: string
{
    case None = 'none';
    case Unknown = 'unknown';
    case Minimum = 'minimum';
}
