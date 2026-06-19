@extends('layouts.app', ['title' => 'Edit Rekomendasi - MoodBite'])

@section('content')
<section class="form-card">
    <p class="badge">Admin - Update</p>
    <h1>Edit Rekomendasi Makanan</h1>

    <form action="{{ route('mood-foods.update', $moodFood) }}" method="POST">
        @csrf
        @method('PUT')
        @include('mood-foods.partials.form', ['moodFood' => $moodFood])

        <div class="form-actions">
            <a href="{{ route('mood-foods.index') }}" class="btn btn-light">Batal</a>
            <button type="submit" class="btn btn-primary">Update</button>
        </div>
    </form>
</section>
@endsection