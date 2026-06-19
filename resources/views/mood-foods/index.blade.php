@extends('layouts.app', ['title' => 'MoodBite - Rekomendasi Makanan'])

@section('content')
<section class="hero">
    <div>
        <p class="badge">Mood-Based Food Recommendation</p>
        <h1>Rekomendasi makanan sesuai suasana hati</h1>
        <p>
            MoodBite membantu pengguna mencatat dan mengelola rekomendasi makanan
            berdasarkan mood, kategori, rasa, serta alasan rekomendasi.
        </p>
    </div>

    <div class="hero-summary">
        <strong>{{ $moodFoods->count() }}</strong>
        <span>Total Rekomendasi</span>
    </div>
</section>

@if ($moodFoods->count())
    <section class="section-header">
        <div>
            <h2>Daftar Rekomendasi Makanan</h2>
            <p>Data berikut tersimpan di database dan dapat dikelola melalui fitur CRUD.</p>
        </div>

        <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">
            + Tambah Rekomendasi
        </a>
    </section>

    <section class="grid">
        @foreach ($moodFoods as $moodFood)
            <article class="card">
                <div class="emoji">
                    @php
                        $mood = strtolower($moodFood->mood);
                    @endphp

                    @if ($mood === 'senang' || $mood === 'bahagia' || $mood === 'happy')
                        😊
                    @elseif ($mood === 'sedih' || $mood === 'galau')
                        🥺
                    @elseif ($mood === 'capek' || $mood === 'lelah')
                        😴
                    @elseif ($mood === 'marah' || $mood === 'kesal')
                        😤
                    @elseif ($mood === 'stress' || $mood === 'stres')
                        😵‍💫
                    @else
                        🍽️
                    @endif
                </div>

                <div class="card-body">
                    <div class="card-top">
                        <p class="badge">{{ $moodFood->mood }}</p>

                        @if ($moodFood->is_favorite)
                            <span class="favorite">★ Favorit</span>
                        @endif
                    </div>

                    <h2>{{ $moodFood->food_name }}</h2>

                    <p class="meta">
                        {{ $moodFood->category }}
                        @if ($moodFood->taste)
                            • {{ $moodFood->taste }}
                        @endif
                    </p>

                    <p class="reason">
                        {{ \Illuminate\Support\Str::limit($moodFood->reason, 100) }}
                    </p>

                    <div class="actions">
                        <a href="{{ route('mood-foods.show', $moodFood) }}" class="btn btn-light">
                            Detail
                        </a>

                        <a href="{{ route('mood-foods.edit', $moodFood) }}" class="btn btn-warning">
                            Edit
                        </a>

                        <form action="{{ route('mood-foods.destroy', $moodFood) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus rekomendasi ini?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger">
                                Hapus
                            </button>
                        </form>
                    </div>
                </div>
            </article>
        @endforeach
    </section>
@else
    <section class="empty">
        <div class="empty-icon">🍜</div>
        <h2>Belum ada rekomendasi makanan</h2>
        <p>
            Tambahkan rekomendasi pertama untuk mulai menggunakan MoodBite.
            Data yang ditambahkan akan tersimpan di database dan dapat diedit atau dihapus.
        </p>

        <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">
            + Tambah Rekomendasi
        </a>
    </section>
@endif
@endsection