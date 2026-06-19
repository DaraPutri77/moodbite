@extends('layouts.app', ['title' => 'Detail Data - MoodBite'])

@section('content')
<section class="detail-card">
    <p class="badge">{{ $moodFood->mood }}</p>
    <h1>{{ $moodFood->food_name }}</h1>

    <p class="meta">
        {{ $moodFood->category }}
        @if ($moodFood->taste)
            • {{ $moodFood->taste }}
        @endif
    </p>

    @if ($moodFood->is_favorite)
        <p class="favorite">★ Favorit</p>
    @endif

    <h3>Alasan Rekomendasi</h3>
    <p>{{ $moodFood->reason }}</p>

    <div class="actions">
        <a href="{{ route('mood-foods.index') }}" class="btn btn-light">Kembali</a>
        <a href="{{ route('mood-foods.edit', $moodFood) }}" class="btn btn-warning">Edit</a>

        <form action="{{ route('mood-foods.destroy', $moodFood) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus data ini?')">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger">Hapus</button>
        </form>
    </div>
</section>
@endsection