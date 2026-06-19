<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MoodFood extends Model
{
    protected $table = 'mood_foods';

    protected $fillable = [
        'mood',
        'food_name',
        'category',
        'taste',
        'reason',
        'is_favorite',
    ];

    protected $casts = [
        'is_favorite' => 'boolean',
    ];
}