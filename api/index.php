<?php

declare(strict_types=1);

ini_set('display_errors', '0');
error_reporting(E_ALL);

function e(?string $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function env_value(string $key, ?string $default = null): ?string
{
    $value = getenv($key);
    if ($value === false || $value === '') {
        return $default;
    }
    return $value;
}

function db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $connection = env_value('DB_CONNECTION', 'pgsql');
    $host = env_value('DB_HOST', '127.0.0.1');
    $port = env_value('DB_PORT', $connection === 'mysql' ? '3306' : '5432');
    $database = env_value('DB_DATABASE', 'neondb');
    $username = env_value('DB_USERNAME', 'root');
    $password = env_value('DB_PASSWORD', '');
    $sslmode = env_value('DB_SSLMODE', 'require');

    if ($connection === 'mysql') {
        $dsn = "mysql:host={$host};port={$port};dbname={$database};charset=utf8mb4";
    } else {
        $dsn = "pgsql:host={$host};port={$port};dbname={$database};sslmode={$sslmode}";
    }

    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    return $pdo;
}

function ensure_table(): void
{
    db()->exec(<<<SQL
CREATE TABLE IF NOT EXISTS mood_foods (
    id BIGSERIAL PRIMARY KEY,
    mood VARCHAR(100) NOT NULL,
    food_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    taste VARCHAR(100),
    reason TEXT NOT NULL,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
)
SQL);
}

function get_all_foods(): array
{
    $stmt = db()->query('SELECT * FROM mood_foods ORDER BY created_at DESC NULLS LAST, id DESC');
    return $stmt->fetchAll();
}

function get_food(int $id): ?array
{
    $stmt = db()->prepare('SELECT * FROM mood_foods WHERE id = :id LIMIT 1');
    $stmt->execute(['id' => $id]);
    $food = $stmt->fetch();
    return $food ?: null;
}

function redirect_to(string $path): never
{
    header('Location: ' . $path, true, 302);
    exit;
}

function emoji_for(string $mood): string
{
    $m = mb_strtolower($mood);
    return match ($m) {
        'senang', 'bahagia', 'happy' => 'ðŸ˜Š',
        'sedih', 'galau' => 'ðŸ¥º',
        'capek', 'lelah' => 'ðŸ˜´',
        'marah', 'kesal' => 'ðŸ˜¤',
        'stress', 'stres' => 'ðŸ˜µâ€ðŸ’«',
        default => 'ðŸ½ï¸',
    };
}

function short_text(string $text, int $limit = 110): string
{
    if (mb_strlen($text) <= $limit) {
        return $text;
    }
    return mb_substr($text, 0, $limit) . '...';
}

function page_start(string $title, bool $admin = false): void
{
    $adminButton = $admin ? '<a class="btn btn-primary" href="/admin/rekomendasi/create">+ Tambah Rekomendasi</a>' : '';
    echo '<!DOCTYPE html><html lang="id"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>' . e($title) . '</title>';
    echo '<style>
*{box-sizing:border-box}body{margin:0;font-family:Arial,sans-serif;background:#fff7ed;color:#2f1b12}.navbar{background:#7c2d12;color:#fff;padding:18px 8%;display:flex;justify-content:space-between;align-items:center;gap:18px;flex-wrap:wrap}.brand{color:#fff;font-weight:800;text-decoration:none;font-size:24px;display:flex;gap:10px;align-items:center}.nav-actions{display:flex;gap:14px;align-items:center;flex-wrap:wrap}.nav-link{color:#ffedd5;text-decoration:none;font-weight:800}.container{width:min(1120px,92%);margin:34px auto}.hero,.empty,.detail-card,.form-card{background:#fff;border-radius:22px;padding:34px;box-shadow:0 14px 35px rgba(124,45,18,.12);margin-bottom:26px}.hero{display:flex;justify-content:space-between;gap:28px;align-items:center}.hero h1{max-width:760px}.hero p{max-width:780px}.hero-summary{min-width:170px;background:#ffedd5;color:#7c2d12;border-radius:18px;padding:22px;text-align:center}.hero-summary strong{display:block;font-size:42px;line-height:1}.hero-summary span{display:block;margin-top:8px;font-weight:700}h1{margin:10px 0;font-size:38px;line-height:1.2}h2{margin:0 0 8px}p{line-height:1.6}.badge{display:inline-block;background:#ffedd5;color:#9a3412;padding:7px 13px;border-radius:999px;font-weight:800;font-size:13px}.section-header{display:flex;justify-content:space-between;align-items:center;margin:28px 0 18px;gap:18px}.section-header p{margin:0;color:#7c2d12}.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px}.card{background:#fff;border-radius:20px;overflow:hidden;box-shadow:0 12px 28px rgba(124,45,18,.10)}.emoji{height:135px;display:grid;place-items:center;font-size:58px;background:linear-gradient(135deg,#ffedd5,#fed7aa)}.card-body{padding:20px}.card-top{display:flex;justify-content:space-between;gap:10px;align-items:center;margin-bottom:10px}.meta{color:#7c2d12;font-weight:700}.reason{color:#4b2f25}.favorite{color:#ca8a04;font-weight:800;font-size:14px}.actions,.form-actions{display:flex;gap:8px;flex-wrap:wrap;align-items:center;margin-top:18px}.btn{border:0;border-radius:12px;padding:11px 16px;text-decoration:none;cursor:pointer;display:inline-block;font-weight:800;font-size:14px}.btn-primary{background:#ea580c;color:#fff}.btn-light{background:#ffedd5;color:#7c2d12}.btn-warning{background:#facc15;color:#422006}.btn-danger{background:#dc2626;color:#fff}.alert{background:#dcfce7;color:#166534;padding:14px 18px;border-radius:14px;margin-bottom:20px;font-weight:700}.empty{text-align:center}.empty-icon{font-size:56px;margin-bottom:12px}input,textarea{width:100%;padding:12px 14px;border:1px solid #fed7aa;border-radius:12px;margin:8px 0 14px;font-size:15px}label{font-weight:800}.checkbox{display:flex;gap:10px;align-items:center;margin-top:8px}.checkbox input{width:auto}.admin-note{background:#fff3cd;border-left:5px solid #f59e0b;padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:700}.table-wrap{overflow:auto;background:white;border-radius:20px;box-shadow:0 12px 28px rgba(124,45,18,.10)}table{width:100%;border-collapse:collapse}th,td{padding:14px;border-bottom:1px solid #fed7aa;text-align:left}th{background:#ffedd5;color:#7c2d12}@media(max-width:700px){.navbar,.hero,.section-header{flex-direction:column;align-items:stretch}h1{font-size:30px}}
</style></head><body>';
    echo '<nav class="navbar"><a class="brand" href="/"><span>ðŸ½ï¸</span><span>MoodBite</span></a><div class="nav-actions"><a class="nav-link" href="/">Dashboard Pengguna</a><a class="nav-link" href="/admin/rekomendasi">Dashboard Admin</a>' . $adminButton . '</div></nav><main class="container">';
}

function page_end(): void
{
    echo '</main></body></html>';
}

function render_user_dashboard(): void
{
    $foods = get_all_foods();
    page_start('MoodBite - Dashboard Pengguna');
    echo '<section class="hero"><div><p class="badge">Dashboard Pengguna</p><h1>Temukan makanan yang cocok dengan suasana hatimu</h1><p>MoodBite menampilkan rekomendasi makanan berdasarkan mood, kategori, rasa, dan alasan rekomendasi. Pengguna hanya melihat rekomendasi, sedangkan data dikelola oleh admin.</p></div><div class="hero-summary"><strong>' . count($foods) . '</strong><span>Total Rekomendasi</span></div></section>';
    echo '<section class="section-header"><div><h2>Rekomendasi untuk Pengguna</h2><p>Pilih makanan yang paling sesuai dengan suasana hatimu.</p></div></section>';

    if (!$foods) {
        echo '<section class="empty"><div class="empty-icon">ðŸœ</div><h2>Belum ada rekomendasi makanan</h2><p>Rekomendasi makanan belum tersedia. Admin dapat menambahkan data melalui dashboard admin.</p></section>';
        page_end();
        return;
    }

    echo '<section class="grid">';
    foreach ($foods as $food) {
        echo '<article class="card"><div class="emoji">' . emoji_for($food['mood']) . '</div><div class="card-body"><div class="card-top"><p class="badge">' . e($food['mood']) . '</p>';
        if (!empty($food['is_favorite'])) echo '<span class="favorite">â˜… Rekomendasi Favorit</span>';
        echo '</div><h2>' . e($food['food_name']) . '</h2><p class="meta">' . e($food['category']);
        if (!empty($food['taste'])) echo ' â€¢ ' . e($food['taste']);
        echo '</p><p class="reason">' . e($food['reason']) . '</p></div></article>';
    }
    echo '</section>';
    page_end();
}

function render_admin_dashboard(): void
{
    $foods = get_all_foods();
    page_start('MoodBite - Dashboard Admin', true);
    echo '<section class="hero"><div><p class="badge">Dashboard Admin</p><h1>Kelola data rekomendasi makanan</h1><p>Halaman ini digunakan admin untuk menambahkan, melihat, mengedit, dan menghapus data rekomendasi makanan.</p></div><div class="hero-summary"><strong>' . count($foods) . '</strong><span>Total Data</span></div></section>';
    echo '<div class="admin-note">Mode admin: CRUD lengkap aktif. Dashboard pengguna hanya menampilkan data.</div>';

    if (!$foods) {
        echo '<section class="empty"><div class="empty-icon">ðŸœ</div><h2>Belum ada data rekomendasi</h2><p>Tambahkan data pertama untuk mulai menggunakan MoodBite.</p><a href="/admin/rekomendasi/create" class="btn btn-primary">+ Tambah Rekomendasi</a></section>';
        page_end();
        return;
    }

    echo '<section class="grid">';
    foreach ($foods as $food) {
        echo '<article class="card"><div class="emoji">' . emoji_for($food['mood']) . '</div><div class="card-body"><div class="card-top"><p class="badge">' . e($food['mood']) . '</p>';
        if (!empty($food['is_favorite'])) echo '<span class="favorite">â˜… Favorit</span>';
        echo '</div><h2>' . e($food['food_name']) . '</h2><p class="meta">' . e($food['category']);
        if (!empty($food['taste'])) echo ' â€¢ ' . e($food['taste']);
        echo '</p><p class="reason">' . e(short_text($food['reason'])) . '</p><div class="actions"><a href="/admin/rekomendasi/' . (int)$food['id'] . '" class="btn btn-light">Detail</a><a href="/admin/rekomendasi/' . (int)$food['id'] . '/edit" class="btn btn-warning">Edit</a><form method="POST" action="/admin/rekomendasi/' . (int)$food['id'] . '/delete" onsubmit="return confirm(\'Yakin ingin menghapus rekomendasi ini?\')"><button class="btn btn-danger" type="submit">Hapus</button></form></div></div></article>';
    }
    echo '</section>';
    page_end();
}

function render_form(?array $food = null): void
{
    $isEdit = $food !== null;
    page_start($isEdit ? 'Edit Rekomendasi - MoodBite' : 'Tambah Rekomendasi - MoodBite', true);
    echo '<section class="form-card"><p class="badge">' . ($isEdit ? 'Edit' : 'Create') . '</p><h1>' . ($isEdit ? 'Edit Rekomendasi Makanan' : 'Tambah Rekomendasi Makanan') . '</h1>';
    echo '<form method="POST" action="' . ($isEdit ? '/admin/rekomendasi/' . (int)$food['id'] . '/update' : '/admin/rekomendasi/store') . '">';
    echo '<label>Mood</label><input name="mood" required placeholder="Contoh: Bahagia, Sedih, Capek" value="' . e($food['mood'] ?? '') . '">';
    echo '<label>Nama Makanan</label><input name="food_name" required placeholder="Contoh: Bakso hangat" value="' . e($food['food_name'] ?? '') . '">';
    echo '<label>Kategori</label><input name="category" required placeholder="Contoh: Comfort Food" value="' . e($food['category'] ?? '') . '">';
    echo '<label>Rasa / Sensasi</label><input name="taste" placeholder="Contoh: Gurih, pedas, hangat" value="' . e($food['taste'] ?? '') . '">';
    echo '<label>Alasan Rekomendasi</label><textarea name="reason" rows="5" required placeholder="Jelaskan kenapa makanan ini cocok untuk mood tersebut">' . e($food['reason'] ?? '') . '</textarea>';
    $checked = !empty($food['is_favorite']) ? 'checked' : '';
    echo '<label class="checkbox"><input type="checkbox" name="is_favorite" value="1" ' . $checked . '> Tandai sebagai favorit</label>';
    echo '<div class="form-actions"><a href="/admin/rekomendasi" class="btn btn-light">Batal</a><button class="btn btn-primary" type="submit">' . ($isEdit ? 'Update' : 'Simpan') . '</button></div></form></section>';
    page_end();
}

function render_detail(int $id): void
{
    $food = get_food($id);
    if (!$food) { http_response_code(404); page_start('Data tidak ditemukan', true); echo '<section class="empty"><h1>Data tidak ditemukan</h1><a class="btn btn-light" href="/admin/rekomendasi">Kembali</a></section>'; page_end(); return; }
    page_start('Detail Rekomendasi - MoodBite', true);
    echo '<section class="detail-card"><p class="badge">' . e($food['mood']) . '</p><h1>' . e($food['food_name']) . '</h1><p class="meta">' . e($food['category']);
    if (!empty($food['taste'])) echo ' â€¢ ' . e($food['taste']);
    echo '</p>';
    if (!empty($food['is_favorite'])) echo '<p class="favorite">â˜… Favorit</p>';
    echo '<h3>Alasan Rekomendasi</h3><p>' . e($food['reason']) . '</p><div class="actions"><a class="btn btn-light" href="/admin/rekomendasi">Kembali</a><a class="btn btn-warning" href="/admin/rekomendasi/' . (int)$food['id'] . '/edit">Edit</a><form method="POST" action="/admin/rekomendasi/' . (int)$food['id'] . '/delete" onsubmit="return confirm(\'Yakin ingin menghapus rekomendasi ini?\')"><button class="btn btn-danger" type="submit">Hapus</button></form></div></section>';
    page_end();
}

function save_food(?int $id = null): void
{
    $data = [
        'mood' => trim($_POST['mood'] ?? ''),
        'food_name' => trim($_POST['food_name'] ?? ''),
        'category' => trim($_POST['category'] ?? ''),
        'taste' => trim($_POST['taste'] ?? ''),
        'reason' => trim($_POST['reason'] ?? ''),
        'is_favorite' => isset($_POST['is_favorite']) ? 1 : 0,
    ];

    if ($data['mood'] === '' || $data['food_name'] === '' || $data['category'] === '' || $data['reason'] === '') {
        http_response_code(422);
        page_start('Validasi gagal', true);
        echo '<section class="empty"><h1>Data belum lengkap</h1><p>Mood, nama makanan, kategori, dan alasan wajib diisi.</p><a class="btn btn-light" href="/admin/rekomendasi">Kembali</a></section>';
        page_end();
        return;
    }

    if ($id === null) {
        $stmt = db()->prepare('INSERT INTO mood_foods (mood, food_name, category, taste, reason, is_favorite, created_at, updated_at) VALUES (:mood, :food_name, :category, :taste, :reason, :is_favorite, NOW(), NOW())');
    } else {
        $stmt = db()->prepare('UPDATE mood_foods SET mood=:mood, food_name=:food_name, category=:category, taste=:taste, reason=:reason, is_favorite=:is_favorite, updated_at=NOW() WHERE id=:id');
        $data['id'] = $id;
    }
    $stmt->execute($data);
    redirect_to('/admin/rekomendasi');
}

function delete_food(int $id): void
{
    $stmt = db()->prepare('DELETE FROM mood_foods WHERE id = :id');
    $stmt->execute(['id' => $id]);
    redirect_to('/admin/rekomendasi');
}

try {
    ensure_table();

    $path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
    $path = rtrim($path, '/') ?: '/';
    $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

    if ($method === 'GET' && $path === '/') {
        render_user_dashboard();
        exit;
    }

    if ($method === 'GET' && $path === '/admin/rekomendasi') {
        render_admin_dashboard();
        exit;
    }

    if ($method === 'GET' && $path === '/admin/rekomendasi/create') {
        render_form();
        exit;
    }

    if ($method === 'POST' && $path === '/admin/rekomendasi/store') {
        save_food();
        exit;
    }

    if (preg_match('#^/admin/rekomendasi/(\d+)$#', $path, $m) && $method === 'GET') {
        render_detail((int) $m[1]);
        exit;
    }

    if (preg_match('#^/admin/rekomendasi/(\d+)/edit$#', $path, $m) && $method === 'GET') {
        $food = get_food((int) $m[1]);
        if (!$food) { redirect_to('/admin/rekomendasi'); }
        render_form($food);
        exit;
    }

    if (preg_match('#^/admin/rekomendasi/(\d+)/update$#', $path, $m) && $method === 'POST') {
        save_food((int) $m[1]);
        exit;
    }

    if (preg_match('#^/admin/rekomendasi/(\d+)/delete$#', $path, $m) && $method === 'POST') {
        delete_food((int) $m[1]);
        exit;
    }

    http_response_code(404);
    page_start('404 - MoodBite');
    echo '<section class="empty"><h1>404 - Halaman tidak ditemukan</h1><p>Halaman yang kamu buka tidak tersedia.</p><a class="btn btn-primary" href="/">Kembali ke Dashboard Pengguna</a></section>';
    page_end();
} catch (Throwable $e) {
    http_response_code(500);
    echo '<!DOCTYPE html><html lang="id"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>MoodBite Error</title></head><body style="font-family:Arial,sans-serif;padding:40px;background:#fff7ed;color:#2f1b12"><h1>MoodBite belum dapat terhubung ke database</h1><p>Periksa Environment Variables database cloud di Vercel.</p><pre style="white-space:pre-wrap;background:#fff;padding:16px;border-radius:12px">' . e($e->getMessage()) . '</pre></body></html>';
}