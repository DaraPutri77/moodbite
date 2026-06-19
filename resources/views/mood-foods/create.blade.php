@extends('layouts.app', ['title' => 'Tambah Rekomendasi - MoodBite'])

@section('content')
<section class="form-card">
    <p class="badge">Admin - Create</p>
    <h1>Tambah Rekomendasi Makanan</h1>

    <form action="{{ route('mood-foods.store') }}" method="POST">
        @csrf
        @include('mood-foods.partials.form', ['moodFood' => null])

        <div class="form-actions">
            <a href="{{ route('mood-foods.index') }}" class="btn btn-light">Batal</a>
            <button type="submit" class="btn btn-primary">Simpan</button>
        </div>
    </form>
</section>
@endsection