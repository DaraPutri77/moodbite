<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'MoodBite' }}</title>
    <link rel="stylesheet" href="{{ asset('css/moodbite.css') }}">
</head>
<body>
    @php
        $isAdminPage = request()->routeIs('mood-foods.*');
    @endphp

    <nav class="navbar">
        <a href="{{ route('home') }}" class="brand">
            <span class="brand-icon">🍽️</span>
            <span>MoodBite</span>
        </a>

        <div class="nav-actions">
            <a href="{{ route('home') }}" class="nav-link">
                Dashboard Pengguna
            </a>

            <a href="{{ route('mood-foods.index') }}" class="nav-link">
                Dashboard Admin
            </a>

            @if ($isAdminPage && !request()->routeIs('mood-foods.create'))
                <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">
                    + Tambah Rekomendasi
                </a>
            @endif
        </div>
    </nav>

    <main class="container">
        @if (session('success'))
            <div class="alert">
                {{ session('success') }}
            </div>
        @endif

        @yield('content')
    </main>
</body>
</html>