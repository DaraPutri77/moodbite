<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\MoodFoodController;

Route::get('/', [MoodFoodController::class, 'home'])->name('home');
Route::redirect('/mood-foods', '/admin/rekomendasi');

Route::prefix('admin')->group(function () {
    Route::resource('rekomendasi', MoodFoodController::class)
        ->parameters(['rekomendasi' => 'moodFood'])
        ->names('mood-foods');
});