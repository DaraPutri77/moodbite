<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mood_foods', function (Blueprint $table) {
            $table->id();
            $table->string('mood', 100);
            $table->string('food_name', 150);
            $table->string('category', 100);
            $table->string('taste', 100)->nullable();
            $table->text('reason');
            $table->boolean('is_favorite')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mood_foods');
    }
};