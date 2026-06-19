$ErrorActionPreference = 'Stop'

$root = (Get-Location).Path
$apiDir = Join-Path $root 'api'
if (!(Test-Path $apiDir)) { New-Item -ItemType Directory -Path $apiDir | Out-Null }

$apiPath = Join-Path $apiDir 'index.php'
$vercelPath = Join-Path $root 'vercel.json'

$php = @'
<?php

error_reporting(E_ALL & ~E_DEPRECATED & ~E_NOTICE & ~E_WARNING);
ini_set('display_errors', '0');

function h($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function current_path() {
    $path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
    return rtrim($path, '/') ?: '/';
}

function method() {
    $method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    if ($method === 'POST' && isset($_POST['_method'])) {
        $method = strtoupper($_POST['_method']);
    }
    return $method;
}

function redirect_to($path) {
    header('Location: ' . $path, true, 302);
    exit;
}

function db() {
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = getenv('DB_HOST') ?: '';
    $port = getenv('DB_PORT') ?: '5432';
    $database = getenv('DB_DATABASE') ?: '';
    $username = getenv('DB_USERNAME') ?: '';
    $password = getenv('DB_PASSWORD') ?: '';
    $sslmode = getenv('DB_SSLMODE') ?: 'require';

    if ($host === '' || $database === '' || $username === '') {
        throw new Exception('Environment database Vercel belum lengkap. Cek DB_HOST, DB_DATABASE, DB_USERNAME, DB_PASSWORD, dan DB_SSLMODE.');
    }

    $dsn = "pgsql:host={$host};port={$port};dbname={$database};sslmode={$sslmode}";
    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    $pdo->exec("CREATE TABLE IF NOT EXISTS mood_foods (
        id BIGSERIAL PRIMARY KEY,
        mood VARCHAR(100) NOT NULL,
        food_name VARCHAR(150) NOT NULL,
        category VARCHAR(100) NOT NULL,
        taste VARCHAR(100),
        reason TEXT NOT NULL,
        is_favorite BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP NULL,
        updated_at TIMESTAMP NULL
    )");

    return $pdo;
}

function all_foods() {
    $stmt = db()->query('SELECT * FROM mood_foods ORDER BY id DESC');
    return $stmt->fetchAll();
}

function find_food($id) {
    $stmt = db()->prepare('SELECT * FROM mood_foods WHERE id = :id');
    $stmt->execute(['id' => $id]);
    $food = $stmt->fetch();
    if (!$food) {
        http_response_code(404);
        page('Data tidak ditemukan', '<section class="panel"><h1>Data tidak ditemukan</h1><p>Rekomendasi yang dicari tidak tersedia.</p><a class="btn" href="/admin/rekomendasi">Kembali</a></section>');
        exit;
    }
    return $food;
}

function mood_icon($mood) {
    $m = strtolower((string) $mood);
    if (in_array($m, ['senang', 'bahagia', 'happy'])) return '😊';
    if (in_array($m, ['sedih', 'galau'])) return '🥺';
    if (in_array($m, ['capek', 'lelah'])) return '😴';
    if (in_array($m, ['marah', 'kesal'])) return '😤';
    if (in_array($m, ['stress', 'stres'])) return '😵‍💫';
    if (in_array($m, ['santai'])) return '😌';
    return '🍽️';
}

function page($title, $content, $isAdmin = false) {
    $add = $isAdmin ? '<a href="/admin/rekomendasi/create" class="btn primary">+ Tambah Rekomendasi</a>' : '';
    echo '<!doctype html><html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>' . h($title) . '</title><style>
        *{box-sizing:border-box}body{margin:0;font-family:Arial,sans-serif;background:#fff7ed;color:#2f1b12}.navbar{background:#7c2d12;color:white;padding:18px 8%;display:flex;justify-content:space-between;align-items:center;gap:16px;flex-wrap:wrap}.brand{color:white;text-decoration:none;font-size:26px;font-weight:900}.nav{display:flex;gap:14px;align-items:center;flex-wrap:wrap}.nav a{color:#ffedd5;text-decoration:none;font-weight:800}.container{width:min(1120px,92%);margin:34px auto}.hero,.panel{background:white;border-radius:22px;padding:34px;box-shadow:0 14px 35px rgba(124,45,18,.12);margin-bottom:26px}.hero{display:flex;justify-content:space-between;gap:28px;align-items:center}.badge{display:inline-block;background:#ffedd5;color:#9a3412;padding:7px 13px;border-radius:999px;font-weight:900;font-size:13px}h1{font-size:38px;line-height:1.2;margin:12px 0}p{line-height:1.6}.summary{min-width:170px;background:#ffedd5;color:#7c2d12;border-radius:18px;padding:22px;text-align:center}.summary strong{display:block;font-size:42px}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px}.card{background:white;border-radius:20px;overflow:hidden;box-shadow:0 12px 28px rgba(124,45,18,.10)}.emoji{height:135px;display:grid;place-items:center;font-size:58px;background:linear-gradient(135deg,#ffedd5,#fed7aa)}.card-body{padding:20px}.top{display:flex;justify-content:space-between;gap:10px;align-items:center;margin-bottom:10px}.meta{color:#7c2d12;font-weight:800}.favorite{color:#ca8a04;font-weight:900}.actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:18px}.btn,button{border:0;border-radius:12px;padding:11px 16px;text-decoration:none;cursor:pointer;display:inline-block;font-weight:900;font-size:14px;background:#ffedd5;color:#7c2d12}.primary{background:#ea580c;color:white!important}.warning{background:#facc15;color:#422006}.danger{background:#dc2626;color:white}input,textarea{width:100%;padding:12px 14px;border:1px solid #fed7aa;border-radius:12px;margin:8px 0 14px;font-size:15px}label{font-weight:900}.alert{background:#dcfce7;color:#166534;padding:14px 18px;border-radius:14px;margin-bottom:20px;font-weight:800}.errorbox{background:#fee2e2;color:#7f1d1d;border-radius:16px;padding:20px}.small{font-size:13px;color:#7c2d12}@media(max-width:700px){.hero{flex-direction:column;align-items:stretch}h1{font-size:30px}}
    </style></head><body><nav class="navbar"><a class="brand" href="/">🍽️ MoodBite</a><div class="nav"><a href="/">Dashboard Pengguna</a><a href="/admin/rekomendasi">Dashboard Admin</a>' . $add . '</div></nav><main class="container">' . $content . '</main></body></html>';
}

function card($food, $admin = false) {
    $id = (int) $food['id'];
    $reason = $admin ? mb_strimwidth((string) $food['reason'], 0, 130, '...') : $food['reason'];
    $actions = $admin ? '<div class="actions"><a class="btn" href="/admin/rekomendasi/' . $id . '">Detail</a><a class="btn warning" href="/admin/rekomendasi/' . $id . '/edit">Edit</a><form method="post" action="/admin/rekomendasi/' . $id . '" onsubmit="return confirm(\'Yakin ingin menghapus rekomendasi ini?\')"><input type="hidden" name="_method" value="DELETE"><button class="danger" type="submit">Hapus</button></form></div>' : '';
    return '<article class="card"><div class="emoji">' . mood_icon($food['mood']) . '</div><div class="card-body"><div class="top"><span class="badge">' . h($food['mood']) . '</span>' . (!empty($food['is_favorite']) ? '<span class="favorite">★ Favorit</span>' : '') . '</div><h2>' . h($food['food_name']) . '</h2><p class="meta">' . h($food['category']) . (!empty($food['taste']) ? ' • ' . h($food['taste']) : '') . '</p><p>' . h($reason) . '</p>' . $actions . '</div></article>';
}

function form_html($action, $food = null) {
    $isEdit = $food !== null;
    $method = $isEdit ? '<input type="hidden" name="_method" value="PUT">' : '';
    $fav = $food && !empty($food['is_favorite']) ? 'checked' : '';
    return '<section class="panel"><p class="badge">' . ($isEdit ? 'Update' : 'Create') . '</p><h1>' . ($isEdit ? 'Edit' : 'Tambah') . ' Rekomendasi Makanan</h1><form method="post" action="' . h($action) . '">' . $method . '
        <label>Mood</label><input name="mood" value="' . h($food['mood'] ?? '') . '" placeholder="Contoh: Bahagia, Sedih, Capek" required>
        <label>Nama Makanan</label><input name="food_name" value="' . h($food['food_name'] ?? '') . '" placeholder="Contoh: Sup Ayam Hangat" required>
        <label>Kategori</label><input name="category" value="' . h($food['category'] ?? '') . '" placeholder="Contoh: Comfort Food" required>
        <label>Rasa / Sensasi</label><input name="taste" value="' . h($food['taste'] ?? '') . '" placeholder="Contoh: Gurih dan hangat">
        <label>Alasan Rekomendasi</label><textarea name="reason" rows="5" required placeholder="Jelaskan kenapa makanan ini cocok untuk mood tersebut">' . h($food['reason'] ?? '') . '</textarea>
        <label><input style="width:auto" type="checkbox" name="is_favorite" value="1" ' . $fav . '> Tandai sebagai favorit</label>
        <div class="actions"><a class="btn" href="/admin/rekomendasi">Batal</a><button class="primary" type="submit">Simpan</button></div>
    </form></section>';
}

try {
    $path = current_path();
    $method = method();

    if ($path === '/mood-foods') redirect_to('/admin/rekomendasi');

    if ($method === 'GET' && $path === '/') {
        $foods = all_foods();
        $html = '<section class="hero"><div><p class="badge">Dashboard Pengguna</p><h1>Temukan makanan yang cocok dengan suasana hatimu</h1><p>MoodBite menampilkan rekomendasi makanan berdasarkan mood, kategori, rasa, dan alasan rekomendasi. Pengguna hanya melihat rekomendasi, sedangkan data dikelola oleh admin.</p></div><div class="summary"><strong>' . count($foods) . '</strong><span>Total Rekomendasi</span></div></section>';
        $html .= '<h2>Rekomendasi untuk Pengguna</h2><p class="small">Pilih makanan yang paling sesuai dengan suasana hatimu.</p>';
        $html .= $foods ? '<section class="grid">' . implode('', array_map(fn($f) => card($f, false), $foods)) . '</section>' : '<section class="panel"><h2>Belum ada rekomendasi makanan</h2><p>Admin dapat menambahkan data melalui dashboard admin.</p></section>';
        page('MoodBite - Dashboard Pengguna', $html, false);
        exit;
    }

    if ($method === 'GET' && $path === '/admin/rekomendasi') {
        $foods = all_foods();
        $html = '<section class="hero"><div><p class="badge">Dashboard Admin</p><h1>Kelola Rekomendasi Makanan</h1><p>Admin dapat menambahkan, melihat, mengedit, dan menghapus data rekomendasi makanan yang tersimpan di database cloud.</p></div><div class="summary"><strong>' . count($foods) . '</strong><span>Total Data</span></div></section>';
        $html .= '<h2>Daftar Rekomendasi Makanan</h2><p class="small">Data berikut tersimpan di database Neon dan dapat dikelola melalui fitur CRUD.</p>';
        $html .= $foods ? '<section class="grid">' . implode('', array_map(fn($f) => card($f, true), $foods)) . '</section>' : '<section class="panel"><h2>Belum ada data</h2><a class="btn primary" href="/admin/rekomendasi/create">+ Tambah Rekomendasi</a></section>';
        page('MoodBite - Dashboard Admin', $html, true);
        exit;
    }

    if ($method === 'GET' && $path === '/admin/rekomendasi/create') {
        page('Tambah Rekomendasi - MoodBite', form_html('/admin/rekomendasi'), true);
        exit;
    }

    if ($method === 'POST' && $path === '/admin/rekomendasi') {
        $stmt = db()->prepare('INSERT INTO mood_foods (mood, food_name, category, taste, reason, is_favorite, created_at, updated_at) VALUES (:mood, :food_name, :category, :taste, :reason, :is_favorite, NOW(), NOW())');
        $stmt->execute([
            'mood' => $_POST['mood'] ?? '',
            'food_name' => $_POST['food_name'] ?? '',
            'category' => $_POST['category'] ?? '',
            'taste' => $_POST['taste'] ?? null,
            'reason' => $_POST['reason'] ?? '',
            'is_favorite' => isset($_POST['is_favorite']) ? 1 : 0,
        ]);
        redirect_to('/admin/rekomendasi');
    }

    if (preg_match('#^/admin/rekomendasi/(\d+)/edit$#', $path, $m)) {
        $food = find_food((int) $m[1]);
        page('Edit Rekomendasi - MoodBite', form_html('/admin/rekomendasi/' . (int)$m[1], $food), true);
        exit;
    }

    if (preg_match('#^/admin/rekomendasi/(\d+)$#', $path, $m)) {
        $id = (int) $m[1];
        if ($method === 'PUT') {
            $stmt = db()->prepare('UPDATE mood_foods SET mood=:mood, food_name=:food_name, category=:category, taste=:taste, reason=:reason, is_favorite=:is_favorite, updated_at=NOW() WHERE id=:id');
            $stmt->execute([
                'id' => $id,
                'mood' => $_POST['mood'] ?? '',
                'food_name' => $_POST['food_name'] ?? '',
                'category' => $_POST['category'] ?? '',
                'taste' => $_POST['taste'] ?? null,
                'reason' => $_POST['reason'] ?? '',
                'is_favorite' => isset($_POST['is_favorite']) ? 1 : 0,
            ]);
            redirect_to('/admin/rekomendasi');
        }
        if ($method === 'DELETE') {
            $stmt = db()->prepare('DELETE FROM mood_foods WHERE id=:id');
            $stmt->execute(['id' => $id]);
            redirect_to('/admin/rekomendasi');
        }
        $food = find_food($id);
        $html = '<section class="panel"><p class="badge">' . h($food['mood']) . '</p><h1>' . h($food['food_name']) . '</h1><p class="meta">' . h($food['category']) . (!empty($food['taste']) ? ' • ' . h($food['taste']) : '') . '</p><h3>Alasan Rekomendasi</h3><p>' . h($food['reason']) . '</p><div class="actions"><a class="btn" href="/admin/rekomendasi">Kembali</a><a class="btn warning" href="/admin/rekomendasi/' . $id . '/edit">Edit</a></div></section>';
        page('Detail Rekomendasi - MoodBite', $html, true);
        exit;
    }

    http_response_code(404);
    page('404 - MoodBite', '<section class="panel"><h1>404</h1><p>Halaman tidak ditemukan.</p><a class="btn" href="/">Kembali ke Dashboard Pengguna</a></section>');
} catch (Throwable $e) {
    http_response_code(500);
    $message = h($e->getMessage());
    page('MoodBite - Error', '<section class="panel errorbox"><h1>Database / Server Error</h1><p>' . $message . '</p><p class="small">Cek Environment Variables Vercel: DB_CONNECTION=pgsql, DB_HOST, DB_PORT=5432, DB_DATABASE=neondb, DB_USERNAME, DB_PASSWORD, DB_SSLMODE=require.</p></section>');
}
'@

$vercel = @'
{
  "version": 2,
  "functions": {
    "api/index.php": {
      "runtime": "vercel-php@0.9.0"
    }
  },
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/api/index.php"
    }
  ]
}
'@

Set-Content -Path $apiPath -Value $php -Encoding UTF8
Set-Content -Path $vercelPath -Value $vercel -Encoding UTF8

Write-Host "OK: api/index.php rescue ditulis" -ForegroundColor Green
Write-Host "OK: vercel.json rescue ditulis" -ForegroundColor Green
Write-Host "Cek awal api/index.php:" -ForegroundColor Cyan
Get-Content $apiPath -TotalCount 3
