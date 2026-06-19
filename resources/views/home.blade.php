@extends('layouts.app', ['title' => 'MoodBite - Dashboard Pengguna'])

@section('content')
<section class="hero">
    <div>
        <p class="badge">Dashboard Pengguna</p>
        <h1>Temukan makanan yang cocok dengan suasana hatimu</h1>
        <p>
            MoodBite menampilkan rekomendasi makanan berdasarkan mood, kategori,
            rasa, dan alasan rekomendasi. Pengguna dapat melihat daftar rekomendasi,
            sedangkan data dikelola oleh admin.
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
            <h2>Rekomendasi untuk Pengguna</h2>
            <p>Pilih makanan yang paling sesuai dengan suasana hatimu.</p>
        </div>
    </section>

    <section class="grid">
        @foreach ($moodFoods as $moodFood)
            <article class="card">
                <div class="emoji">
                    @php $mood = strtolower($moodFood->mood); @endphp

                    @if ($mood === 'senang' || $mood === 'bahagia' || $mood === 'happy')
                        ðŸ˜Š
                    @elseif ($mood === 'sedih' || $mood === 'galau')
                        ðŸ¥º
                    @elseif ($mood === 'capek' || $mood === 'lelah')
                        ðŸ˜´
                    @elseif ($mood === 'marah' || $mood === 'kesal')
                        ðŸ˜¤
                    @elseif ($mood === 'stress' || $mood === 'stres')
                        ðŸ˜µâ€ðŸ’«
                    @else
                        ðŸ½ï¸
                    @endif
                </div>

                <div class="card-body">
                    <div class="card-top">
                        <p class="badge">{{ $moodFood->mood }}</p>
                        @if ($moodFood->is_favorite)
                            <span class="favorite">â˜… Rekomendasi Favorit</span>
                        @endif
                    </div>

                    <h2>{{ $moodFood->food_name }}</h2>
                    <p class="meta">{{ $moodFood->category }} @if ($moodFood->taste) â€¢ {{ $moodFood->taste }} @endif</p>
                    <p class="reason">{{ $moodFood->reason }}</p>
                </div>
            </article>
        @endforeach
    </section>
@else
    <section class="empty">
        <div class="empty-icon">ðŸœ</div>
        <h2>Belum ada rekomendasi makanan</h2>
        <p>Rekomendasi makanan belum tersedia. Admin dapat menambahkan data melalui dashboard admin.</p>
        <a href="{{ route('mood-foods.index') }}" class="btn btn-primary">Masuk Dashboard Admin</a>
    </section>
@endif
@endsection