@extends('layouts.app', ['title' => 'MoodBite - Dashboard Admin'])

@section('content')
<section class="hero">
    <div>
        <p class="badge">Dashboard Admin</p>
        <h1>Kelola rekomendasi makanan MoodBite</h1>
        <p>Halaman ini digunakan admin untuk menambah, melihat, mengedit, dan menghapus data rekomendasi makanan.</p>
    </div>

    <div class="hero-summary">
        <strong>{{ $moodFoods->count() }}</strong>
        <span>Total Rekomendasi</span>
    </div>
</section>

<section class="section-header">
    <div>
        <h2>Daftar Rekomendasi Makanan</h2>
        <p>Data berikut tersimpan di database cloud dan dikelola melalui fitur CRUD.</p>
    </div>

    <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">+ Tambah Rekomendasi</a>
</section>

@if ($moodFoods->count())
    <section class="grid">
        @foreach ($moodFoods as $moodFood)
            <article class="card">
                <div class="emoji">
                    @php $mood = strtolower($moodFood->mood); @endphp
                    @if ($mood === 'senang' || $mood === 'bahagia' || $mood === 'happy') ðŸ˜Š
                    @elseif ($mood === 'sedih' || $mood === 'galau') ðŸ¥º
                    @elseif ($mood === 'capek' || $mood === 'lelah') ðŸ˜´
                    @elseif ($mood === 'marah' || $mood === 'kesal') ðŸ˜¤
                    @elseif ($mood === 'stress' || $mood === 'stres') ðŸ˜µâ€ðŸ’«
                    @else ðŸ½ï¸
                    @endif
                </div>

                <div class="card-body">
                    <div class="card-top">
                        <p class="badge">{{ $moodFood->mood }}</p>
                        @if ($moodFood->is_favorite)
                            <span class="favorite">â˜… Favorit</span>
                        @endif
                    </div>
                    <h2>{{ $moodFood->food_name }}</h2>
                    <p class="meta">{{ $moodFood->category }} @if ($moodFood->taste) â€¢ {{ $moodFood->taste }} @endif</p>
                    <p class="reason">{{ \Illuminate\Support\Str::limit($moodFood->reason, 100) }}</p>
                    <div class="actions">
                        <a href="{{ route('mood-foods.show', $moodFood) }}" class="btn btn-light">Detail</a>
                        <a href="{{ route('mood-foods.edit', $moodFood) }}" class="btn btn-warning">Edit</a>
                        <form action="{{ route('mood-foods.destroy', $moodFood) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus rekomendasi ini?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger">Hapus</button>
                        </form>
                    </div>
                </div>
            </article>
        @endforeach
    </section>
@else
    <section class="empty">
        <div class="empty-icon">ðŸœ</div>
        <h2>Belum ada rekomendasi makanan</h2>
        <p>Tambahkan rekomendasi pertama untuk mulai mengisi data MoodBite.</p>
        <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">+ Tambah Rekomendasi</a>
    </section>
@endif
@endsection