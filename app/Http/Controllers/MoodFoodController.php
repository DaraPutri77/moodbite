<?php

namespace App\Http\Controllers;

use App\Models\MoodFood;
use Illuminate\Http\Request;

class MoodFoodController extends Controller
{
    public function home()
    {
        $moodFoods = MoodFood::latest()->get();

        return view('home', compact('moodFoods'));
    }

    public function index()
    {
        $moodFoods = MoodFood::latest()->get();

        return view('mood-foods.index', compact('moodFoods'));
    }

    public function create()
    {
        return view('mood-foods.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'mood' => 'required|string|max:100',
            'food_name' => 'required|string|max:150',
            'category' => 'required|string|max:100',
            'taste' => 'nullable|string|max:100',
            'reason' => 'required|string',
            'is_favorite' => 'nullable',
        ]);

        $validated['is_favorite'] = $request->has('is_favorite');

        MoodFood::create($validated);

        return redirect()
            ->route('mood-foods.index')
            ->with('success', 'Rekomendasi makanan berhasil ditambahkan.');
    }

    public function show(MoodFood $moodFood)
    {
        return view('mood-foods.show', compact('moodFood'));
    }

    public function edit(MoodFood $moodFood)
    {
        return view('mood-foods.edit', compact('moodFood'));
    }

    public function update(Request $request, MoodFood $moodFood)
    {
        $validated = $request->validate([
            'mood' => 'required|string|max:100',
            'food_name' => 'required|string|max:150',
            'category' => 'required|string|max:100',
            'taste' => 'nullable|string|max:100',
            'reason' => 'required|string',
            'is_favorite' => 'nullable',
        ]);

        $validated['is_favorite'] = $request->has('is_favorite');

        $moodFood->update($validated);

        return redirect()
            ->route('mood-foods.index')
            ->with('success', 'Rekomendasi makanan berhasil diperbarui.');
    }

    public function destroy(MoodFood $moodFood)
    {
        $moodFood->delete();

        return redirect()
            ->route('mood-foods.index')
            ->with('success', 'Rekomendasi makanan berhasil dihapus.');
    }
}