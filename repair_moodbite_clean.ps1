$ErrorActionPreference = "Stop"

function Write-ProjectFile {
    param(
        [string]$Path,
        [string]$Content
    )
    $FullPath = Join-Path (Get-Location) $Path
    $Dir = Split-Path $FullPath -Parent
    if (!(Test-Path $Dir)) {
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
    }
    [System.IO.File]::WriteAllText($FullPath, $Content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "OK: $Path" -ForegroundColor Green
}

Write-ProjectFile "api/index.php" @'
<?php

require __DIR__ . '/../public/index.php';
'@

Write-ProjectFile "public/index.php" @'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

if (file_exists($maintenance = __DIR__ . '/../storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__ . '/../vendor/autoload.php';

/** @var Application $app */
$app = require_once __DIR__ . '/../bootstrap/app.php';

$app->handleRequest(Request::capture());
'@

Write-ProjectFile "bootstrap/app.php" @'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        //
    })
    ->create();
'@

Write-ProjectFile "bootstrap/providers.php" @'
<?php

return [
    App\Providers\AppServiceProvider::class,
];
'@

Write-ProjectFile "app/Providers/AppServiceProvider.php" @'
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        //
    }
}
'@

Write-ProjectFile "app/Models/MoodFood.php" @'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MoodFood extends Model
{
    protected $table = 'mood_foods';

    protected $fillable = [
        'mood',
        'food_name',
        'category',
        'taste',
        'reason',
        'is_favorite',
    ];

    protected $casts = [
        'is_favorite' => 'boolean',
    ];
}
'@

Write-ProjectFile "app/Http/Controllers/MoodFoodController.php" @'
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
'@

Write-ProjectFile "routes/web.php" @'
<?php

use App\Http\Controllers\MoodFoodController;
use Illuminate\Support\Facades\Route;

Route::get('/', [MoodFoodController::class, 'home'])->name('home');

Route::redirect('/mood-foods', '/admin/rekomendasi');

Route::prefix('admin')->group(function () {
    Route::resource('rekomendasi', MoodFoodController::class)
        ->parameters(['rekomendasi' => 'moodFood'])
        ->names('mood-foods');
});
'@

Write-ProjectFile "config/database.php" @'
<?php

use Illuminate\Support\Str;

return [
    'default' => env('DB_CONNECTION', 'sqlite'),

    'connections' => [
        'sqlite' => [
            'driver' => 'sqlite',
            'url' => env('DB_URL'),
            'database' => env('DB_DATABASE', database_path('database.sqlite')),
            'prefix' => '',
            'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
            'busy_timeout' => null,
            'journal_mode' => null,
            'synchronous' => null,
        ],

        'mysql' => [
            'driver' => 'mysql',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'laravel'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'prefix' => '',
            'prefix_indexes' => true,
            'strict' => true,
            'engine' => null,
            'options' => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],

        'pgsql' => [
            'driver' => 'pgsql',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'laravel'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8'),
            'prefix' => '',
            'prefix_indexes' => true,
            'search_path' => 'public',
            'sslmode' => env('DB_SSLMODE', 'prefer'),
        ],
    ],

    'migrations' => [
        'table' => 'migrations',
        'update_date_on_publish' => true,
    ],

    'redis' => [
        'client' => env('REDIS_CLIENT', 'phpredis'),
        'options' => [
            'cluster' => env('REDIS_CLUSTER', 'redis'),
            'prefix' => env('REDIS_PREFIX', Str::slug((string) env('APP_NAME', 'laravel')) . '-database-'),
        ],
        'default' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_DB', '0'),
        ],
        'cache' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_CACHE_DB', '1'),
        ],
    ],
];
'@

Write-ProjectFile "resources/views/layouts/app.blade.php" @'
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
            <a href="{{ route('home') }}" class="nav-link">Dashboard Pengguna</a>
            <a href="{{ route('mood-foods.index') }}" class="nav-link">Dashboard Admin</a>

            @if ($isAdminPage && !request()->routeIs('mood-foods.create'))
                <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">+ Tambah Rekomendasi</a>
            @endif
        </div>
    </nav>

    <main class="container">
        @if (session('success'))
            <div class="alert">{{ session('success') }}</div>
        @endif

        @yield('content')
    </main>
</body>
</html>
'@

Write-ProjectFile "resources/views/home.blade.php" @'
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
                            <span class="favorite">★ Rekomendasi Favorit</span>
                        @endif
                    </div>

                    <h2>{{ $moodFood->food_name }}</h2>
                    <p class="meta">{{ $moodFood->category }} @if ($moodFood->taste) • {{ $moodFood->taste }} @endif</p>
                    <p class="reason">{{ $moodFood->reason }}</p>
                </div>
            </article>
        @endforeach
    </section>
@else
    <section class="empty">
        <div class="empty-icon">🍜</div>
        <h2>Belum ada rekomendasi makanan</h2>
        <p>Rekomendasi makanan belum tersedia. Admin dapat menambahkan data melalui dashboard admin.</p>
        <a href="{{ route('mood-foods.index') }}" class="btn btn-primary">Masuk Dashboard Admin</a>
    </section>
@endif
@endsection
'@

Write-ProjectFile "resources/views/mood-foods/index.blade.php" @'
@extends('layouts.app', ['title' => 'MoodBite - Dashboard Admin'])

@section('content')
<section class="hero">
    <div>
        <p class="badge">Dashboard Admin</p>
        <h1>Kelola rekomendasi makanan MoodBite</h1>
        <p>Halaman ini digunakan admin untuk menambah, melihat, mengubah, dan menghapus data rekomendasi makanan.</p>
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
            <p>Data berikut tersimpan di database cloud dan dikelola melalui fitur CRUD.</p>
        </div>

        <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">+ Tambah Rekomendasi</a>
    </section>

    <section class="grid">
        @foreach ($moodFoods as $moodFood)
            <article class="card">
                <div class="emoji">
                    @php $mood = strtolower($moodFood->mood); @endphp

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
                    <p class="meta">{{ $moodFood->category }} @if($moodFood->taste) • {{ $moodFood->taste }} @endif</p>
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
        <div class="empty-icon">🍜</div>
        <h2>Belum ada rekomendasi makanan</h2>
        <p>Tambahkan rekomendasi pertama agar MoodBite memiliki data yang dapat ditampilkan untuk pengguna.</p>
        <a href="{{ route('mood-foods.create') }}" class="btn btn-primary">+ Tambah Rekomendasi</a>
    </section>
@endif
@endsection
'@

Write-ProjectFile "resources/views/mood-foods/create.blade.php" @'
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
'@

Write-ProjectFile "resources/views/mood-foods/edit.blade.php" @'
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
'@

Write-ProjectFile "resources/views/mood-foods/show.blade.php" @'
@extends('layouts.app', ['title' => 'Detail Rekomendasi - MoodBite'])

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

        <form action="{{ route('mood-foods.destroy', $moodFood) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus rekomendasi ini?')">
            @csrf
            @method('DELETE')
            <button type="submit" class="btn btn-danger">Hapus</button>
        </form>
    </div>
</section>
@endsection
'@

Write-ProjectFile "resources/views/mood-foods/partials/form.blade.php" @'
<label for="mood">Mood</label>
<input type="text" id="mood" name="mood" value="{{ old('mood', $moodFood->mood ?? '') }}" placeholder="Contoh: Bahagia, Sedih, Capek" required>
@error('mood') <small class="error">{{ $message }}</small> @enderror

<label for="food_name">Nama Makanan</label>
<input type="text" id="food_name" name="food_name" value="{{ old('food_name', $moodFood->food_name ?? '') }}" placeholder="Contoh: Bakso hangat" required>
@error('food_name') <small class="error">{{ $message }}</small> @enderror

<label for="category">Kategori</label>
<input type="text" id="category" name="category" value="{{ old('category', $moodFood->category ?? '') }}" placeholder="Contoh: Comfort Food" required>
@error('category') <small class="error">{{ $message }}</small> @enderror

<label for="taste">Rasa / Sensasi</label>
<input type="text" id="taste" name="taste" value="{{ old('taste', $moodFood->taste ?? '') }}" placeholder="Contoh: Gurih, pedas, hangat">
@error('taste') <small class="error">{{ $message }}</small> @enderror

<label for="reason">Alasan Rekomendasi</label>
<textarea id="reason" name="reason" rows="5" placeholder="Jelaskan kenapa makanan ini cocok untuk mood tersebut" required>{{ old('reason', $moodFood->reason ?? '') }}</textarea>
@error('reason') <small class="error">{{ $message }}</small> @enderror

<label class="checkbox">
    <input type="checkbox" name="is_favorite" value="1" @checked(old('is_favorite', $moodFood->is_favorite ?? false))>
    Tandai sebagai favorit
</label>
'@

Write-ProjectFile "public/css/moodbite.css" @'
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: Arial, sans-serif;
    background: #fff7ed;
    color: #2f1b12;
}

.navbar {
    background: #7c2d12;
    color: white;
    padding: 18px 8%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 20px;
}

.brand {
    color: white;
    font-weight: 800;
    text-decoration: none;
    font-size: 24px;
    display: flex;
    gap: 10px;
    align-items: center;
}

.brand-icon { font-size: 26px; }

.nav-actions {
    display: flex;
    gap: 14px;
    align-items: center;
    flex-wrap: wrap;
}

.nav-link {
    color: #ffedd5;
    text-decoration: none;
    font-weight: 800;
}

.nav-link:hover { color: white; }

.container {
    width: min(1120px, 92%);
    margin: 34px auto;
}

.hero, .empty, .detail-card, .form-card {
    background: white;
    border-radius: 22px;
    padding: 34px;
    box-shadow: 0 14px 35px rgba(124, 45, 18, 0.12);
    margin-bottom: 26px;
}

.hero {
    display: flex;
    justify-content: space-between;
    gap: 28px;
    align-items: center;
}

.hero h1 { max-width: 720px; }
.hero p { max-width: 760px; }

.hero-summary {
    min-width: 170px;
    background: #ffedd5;
    color: #7c2d12;
    border-radius: 18px;
    padding: 22px;
    text-align: center;
}

.hero-summary strong {
    display: block;
    font-size: 42px;
    line-height: 1;
}

.hero-summary span {
    display: block;
    margin-top: 8px;
    font-weight: 700;
}

h1 { margin: 10px 0; font-size: 38px; line-height: 1.2; }
h2 { margin: 0 0 8px; }
p { line-height: 1.6; }

.badge {
    display: inline-block;
    background: #ffedd5;
    color: #9a3412;
    padding: 7px 13px;
    border-radius: 999px;
    font-weight: 800;
    font-size: 13px;
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin: 28px 0 18px;
}

.section-header p { margin: 0; color: #7c2d12; }

.grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
}

.card {
    background: white;
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 12px 28px rgba(124, 45, 18, 0.10);
}

.emoji {
    height: 135px;
    display: grid;
    place-items: center;
    font-size: 58px;
    background: linear-gradient(135deg, #ffedd5, #fed7aa);
}

.card-body { padding: 20px; }

.card-top {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    align-items: center;
    margin-bottom: 10px;
}

.meta { color: #7c2d12; font-weight: 700; }
.reason { color: #4b2f25; }
.favorite { color: #ca8a04; font-weight: 800; font-size: 14px; }

.actions, .form-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    align-items: center;
    margin-top: 18px;
}

.btn {
    border: 0;
    border-radius: 12px;
    padding: 11px 16px;
    text-decoration: none;
    cursor: pointer;
    display: inline-block;
    font-weight: 800;
    font-size: 14px;
}

.btn-primary { background: #ea580c; color: white; }
.btn-light { background: #ffedd5; color: #7c2d12; }
.btn-warning { background: #facc15; color: #422006; }
.btn-danger { background: #dc2626; color: white; }

.alert {
    background: #dcfce7;
    color: #166534;
    padding: 14px 18px;
    border-radius: 14px;
    margin-bottom: 20px;
    font-weight: 700;
}

.empty { text-align: center; }
.empty-icon { font-size: 56px; margin-bottom: 12px; }

input, textarea {
    width: 100%;
    padding: 12px 14px;
    border: 1px solid #fed7aa;
    border-radius: 12px;
    margin: 8px 0 14px;
    font-size: 15px;
}

label { font-weight: 800; }

.checkbox {
    display: flex;
    gap: 10px;
    align-items: center;
    margin-top: 8px;
}

.checkbox input { width: auto; }

.error {
    color: #dc2626;
    display: block;
    margin-top: -10px;
    margin-bottom: 12px;
    font-weight: 700;
}

@media (max-width: 700px) {
    .navbar, .hero, .section-header {
        flex-direction: column;
        align-items: stretch;
    }

    h1 { font-size: 30px; }
}
'@

Write-ProjectFile ".vercelignore" @'
/vendor
/node_modules
.env
'@

Write-ProjectFile "vercel.json" @'
{
  "version": 2,
  "framework": null,
  "functions": {
    "api/index.php": {
      "runtime": "vercel-php@0.9.0"
    }
  },
  "routes": [
    {
      "src": "/css/(.*)",
      "dest": "/public/css/$1"
    },
    {
      "src": "/build/(.*)",
      "dest": "/public/build/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/api/index.php"
    }
  ],
  "env": {
    "APP_ENV": "production",
    "APP_CONFIG_CACHE": "/tmp/config.php",
    "APP_ROUTES_CACHE": "/tmp/routes.php",
    "APP_SERVICES_CACHE": "/tmp/services.php",
    "VIEW_COMPILED_PATH": "/tmp",
    "SESSION_DRIVER": "cookie",
    "CACHE_STORE": "array",
    "QUEUE_CONNECTION": "sync",
    "LOG_CHANNEL": "stderr"
  }
}
'@

Write-Host "\nSELESAI: File MoodBite sudah dipulihkan." -ForegroundColor Cyan
Write-Host "Sekarang jalankan perintah PHP lint dan git push sesuai instruksi ChatGPT." -ForegroundColor Yellow
