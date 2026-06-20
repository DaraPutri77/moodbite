$ErrorActionPreference = 'Stop'

Write-Host "=== MoodBite Static Supabase Vercel Fix ===" -ForegroundColor Cyan

$SupabaseUrl = "https://foivzaaqybjkteiqhpet.supabase.co"
$SupabaseKey = Read-Host "Paste SUPABASE PUBLISHABLE KEY (yang default, sb_publishable... atau eyJ...)"

if ([string]::IsNullOrWhiteSpace($SupabaseKey)) {
    throw "Supabase publishable key kosong. Copy key dari Supabase > Settings > API Keys > Publishable key > default."
}

if (!(Test-Path ".\public")) {
    New-Item -ItemType Directory -Path ".\public" | Out-Null
}

$IndexHtml = @'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MoodBite - Dashboard Pengguna</title>
  <style>
    *{box-sizing:border-box} body{margin:0;font-family:Arial,sans-serif;background:#fff7ed;color:#2b140c;line-height:1.55}.nav{background:#7c250c;color:white;padding:22px 8%;display:flex;justify-content:space-between;align-items:center;gap:16px;flex-wrap:wrap}.brand{font-size:28px;font-weight:800}.nav a{color:white;text-decoration:none;font-weight:700;margin-left:18px}.container{padding:36px 8%}.hero,.empty{background:white;border-radius:28px;padding:48px;margin-bottom:32px;box-shadow:0 20px 50px #00000012}.hero{display:flex;justify-content:space-between;gap:24px;align-items:center}.badge{background:#ffedd5;color:#8a2f12;padding:10px 18px;border-radius:999px;display:inline-block;font-weight:800}h1{font-size:46px;max-width:860px;margin:20px 0 12px}.count{background:#ffedd5;border-radius:20px;padding:30px 46px;text-align:center;min-width:210px}.count strong{font-size:52px;color:#8a2f12}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:24px}.card{background:white;border-radius:24px;overflow:hidden;box-shadow:0 20px 50px #00000012}.emoji{background:#fed7aa;text-align:center;font-size:58px;padding:42px}.body{padding:28px}.meta{font-weight:700;color:#7c250c}.favorite{color:#ca8a04;font-weight:800;margin-left:8px}.error{background:#fee2e2;color:#991b1b;border-radius:16px;padding:18px;white-space:pre-wrap} @media(max-width:760px){h1{font-size:34px}.hero{display:block}.count{margin-top:24px}.nav a{display:inline-block;margin:8px 8px 0 0}}
  </style>
</head>
<body>
  <nav class="nav"><div class="brand">🍽️ MoodBite</div><div><a href="/">Dashboard Pengguna</a><a href="/admin/rekomendasi">Dashboard Admin</a></div></nav>
  <main class="container">
    <section class="hero"><div><p class="badge">Dashboard Pengguna</p><h1>Temukan makanan yang cocok dengan suasana hatimu</h1><p>MoodBite menampilkan rekomendasi makanan berdasarkan mood, kategori, rasa, dan alasan rekomendasi. Pengguna hanya melihat rekomendasi, sedangkan data dikelola oleh admin.</p></div><div class="count"><strong id="total">0</strong><br><b>Total Rekomendasi</b></div></section>
    <h2>Rekomendasi untuk Pengguna</h2><p>Pilih makanan yang paling sesuai dengan suasana hatimu.</p><section id="list" class="grid"></section>
  </main>
<script>
const SUPABASE_URL = "__SUPABASE_URL__";
const SUPABASE_KEY = "__SUPABASE_KEY__";
function esc(v){return String(v ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));}
function emoji(mood){mood=(mood||'').toLowerCase(); if(mood.includes('bahagia')||mood.includes('senang'))return '😊'; if(mood.includes('sedih')||mood.includes('galau'))return '🥺'; if(mood.includes('capek')||mood.includes('lelah'))return '😴'; if(mood.includes('stress')||mood.includes('stres'))return '😵‍💫'; if(mood.includes('santai'))return '🍞'; if(mood.includes('marah'))return '🌶️'; return '🍽️';}
async function loadData(){
  const list=document.getElementById('list');
  try{
    const res=await fetch(SUPABASE_URL+"/rest/v1/mood_foods?select=*&order=created_at.desc",{headers:{apikey:SUPABASE_KEY,Authorization:"Bearer "+SUPABASE_KEY}});
    const data=await res.json();
    if(!res.ok) throw new Error(JSON.stringify(data,null,2));
    document.getElementById('total').textContent=Array.isArray(data)?data.length:0;
    if(!Array.isArray(data)||data.length===0){list.innerHTML='<div class="empty"><h2>Belum ada rekomendasi</h2><p>Data belum tersedia.</p></div>'; return;}
    list.innerHTML=data.map(item=>`<article class="card"><div class="emoji">${emoji(item.mood)}</div><div class="body"><p><span class="badge">${esc(item.mood)}</span>${item.is_favorite?'<span class="favorite">★ Favorit</span>':''}</p><h2>${esc(item.food_name)}</h2><p class="meta">${esc(item.category)} • ${esc(item.taste||'-')}</p><p>${esc(item.reason)}</p></div></article>`).join('');
  }catch(e){list.innerHTML='<div class="error"><b>Error koneksi Supabase:</b> '+esc(e.message)+'</div>';}
}
loadData();
</script>
</body>
</html>
'@

$AdminHtml = @'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MoodBite - Dashboard Admin</title>
  <style>
    *{box-sizing:border-box} body{margin:0;font-family:Arial,sans-serif;background:#fff7ed;color:#2b140c;line-height:1.55}.nav{background:#7c250c;color:white;padding:22px 8%;display:flex;justify-content:space-between;align-items:center;gap:16px;flex-wrap:wrap}.brand{font-size:28px;font-weight:800}.nav a{color:white;text-decoration:none;font-weight:700;margin-left:18px}.container{padding:36px 8%}.panel,.card{background:white;border-radius:24px;padding:28px;margin-bottom:24px;box-shadow:0 20px 50px #00000012}input,textarea{width:100%;padding:14px;border:1px solid #fed7aa;border-radius:12px;margin:8px 0 16px;font-size:16px}label{font-weight:800}.btn{background:#f97316;color:white;padding:12px 18px;border-radius:12px;border:0;font-weight:800;cursor:pointer;text-decoration:none;margin:4px}.danger{background:#dc2626}.edit{background:#facc15;color:#2b140c}.row{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px}.badge{background:#ffedd5;color:#8a2f12;padding:8px 14px;border-radius:999px;display:inline-block;font-weight:800}.error{background:#fee2e2;color:#991b1b;border-radius:16px;padding:18px;white-space:pre-wrap} @media(max-width:760px){.nav a{display:inline-block;margin:8px 8px 0 0}}
  </style>
</head>
<body>
  <nav class="nav"><div class="brand">🍽️ MoodBite Admin</div><div><a href="/">Dashboard Pengguna</a><a href="/admin/rekomendasi">Dashboard Admin</a></div></nav>
  <main class="container">
    <section class="panel"><h1>Dashboard Admin Rekomendasi</h1><p>Admin dapat menambah, melihat, mengubah, dan menghapus data rekomendasi makanan. Data tersimpan di database cloud Supabase.</p><input type="hidden" id="id"><label>Mood</label><input id="mood" placeholder="Contoh: Bahagia, Sedih, Capek"><label>Nama Makanan</label><input id="food_name" placeholder="Contoh: Sup Ayam Hangat"><label>Kategori</label><input id="category" placeholder="Contoh: Comfort Food"><label>Rasa / Sensasi</label><input id="taste" placeholder="Contoh: Gurih dan hangat"><label>Alasan Rekomendasi</label><textarea id="reason" rows="4" placeholder="Jelaskan alasan rekomendasi"></textarea><label><input type="checkbox" id="is_favorite" style="width:auto"> Jadikan favorit</label><br><br><button class="btn" onclick="saveData()">Simpan Rekomendasi</button><button class="btn danger" onclick="resetForm()">Reset</button></section>
    <section><h2>Data Rekomendasi</h2><div id="list" class="row"></div></section>
  </main>
<script>
const SUPABASE_URL = "__SUPABASE_URL__";
const SUPABASE_KEY = "__SUPABASE_KEY__";
function esc(v){return String(v ?? '').replace(/[&<>'"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[c]));}
async function request(path,options={}){options.headers={apikey:SUPABASE_KEY,Authorization:"Bearer "+SUPABASE_KEY,"Content-Type":"application/json",Prefer:"return=representation",...(options.headers||{})};return fetch(SUPABASE_URL+path,options)}
async function loadData(){const list=document.getElementById('list');try{const res=await request("/rest/v1/mood_foods?select=*&order=created_at.desc");const data=await res.json();if(!res.ok) throw new Error(JSON.stringify(data,null,2));if(!Array.isArray(data)||data.length===0){list.innerHTML='<div class="card"><h2>Belum ada data</h2><p>Tambahkan rekomendasi pertama melalui form admin.</p></div>';return;}list.innerHTML=data.map(item=>`<div class="card"><p><span class="badge">${esc(item.mood)}</span> ${item.is_favorite?'★ Favorit':''}</p><h2>${esc(item.food_name)}</h2><p><b>${esc(item.category)}</b> • ${esc(item.taste||'-')}</p><p>${esc(item.reason)}</p><button class="btn edit" onclick='editData(${JSON.stringify(item).replace(/'/g,"&#39;")})'>Edit</button><button class="btn danger" onclick="deleteData(${item.id})">Hapus</button></div>`).join('');}catch(e){list.innerHTML='<div class="error"><b>Error database:</b> '+esc(e.message)+'</div>';}}
function resetForm(){id.value='';mood.value='';food_name.value='';category.value='';taste.value='';reason.value='';is_favorite.checked=false;}
function editData(item){id.value=item.id;mood.value=item.mood;food_name.value=item.food_name;category.value=item.category;taste.value=item.taste||'';reason.value=item.reason;is_favorite.checked=!!item.is_favorite;window.scrollTo({top:0,behavior:'smooth'});}
async function saveData(){const payload={mood:mood.value.trim(),food_name:food_name.value.trim(),category:category.value.trim(),taste:taste.value.trim(),reason:reason.value.trim(),is_favorite:is_favorite.checked,updated_at:new Date().toISOString()};if(!payload.mood||!payload.food_name||!payload.category||!payload.reason){alert('Mood, nama makanan, kategori, dan alasan wajib diisi.');return;}try{let res;if(id.value){res=await request("/rest/v1/mood_foods?id=eq."+id.value,{method:"PATCH",body:JSON.stringify(payload)});}else{payload.created_at=new Date().toISOString();res=await request("/rest/v1/mood_foods",{method:"POST",body:JSON.stringify(payload)});}if(!res.ok){const err=await res.json();throw new Error(JSON.stringify(err,null,2));}resetForm();loadData();}catch(e){alert('Gagal simpan: '+e.message);}}
async function deleteData(rowId){if(confirm('Hapus data ini?')){try{const res=await request("/rest/v1/mood_foods?id=eq."+rowId,{method:"DELETE"});if(!res.ok){const err=await res.json();throw new Error(JSON.stringify(err,null,2));}loadData();}catch(e){alert('Gagal hapus: '+e.message);}}}
loadData();
</script>
</body>
</html>
'@

$IndexHtml = $IndexHtml.Replace('__SUPABASE_URL__', $SupabaseUrl).Replace('__SUPABASE_KEY__', $SupabaseKey)
$AdminHtml = $AdminHtml.Replace('__SUPABASE_URL__', $SupabaseUrl).Replace('__SUPABASE_KEY__', $SupabaseKey)

Set-Content -Path ".\index.html" -Value $IndexHtml -Encoding UTF8
Set-Content -Path ".\admin.html" -Value $AdminHtml -Encoding UTF8
Set-Content -Path ".\public\index.html" -Value $IndexHtml -Encoding UTF8
Set-Content -Path ".\public\admin.html" -Value $AdminHtml -Encoding UTF8

@'
{
  "version": 2,
  "routes": [
    { "src": "/admin/rekomendasi", "dest": "/admin.html" },
    { "src": "/admin/?", "dest": "/admin.html" },
    { "src": "/mood-foods/?", "dest": "/admin.html" },
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
'@ | Set-Content -Path ".\vercel.json" -Encoding UTF8

@'
/vendor
/node_modules
.env
composer.json
composer.lock
package.json
package-lock.json
vite.config.js
artisan
api
app
bootstrap
config
database
resources
routes
storage
tests
*.ps1
/public/index.php
/public/.htaccess
'@ | Set-Content -Path ".\.vercelignore" -Encoding UTF8

Write-Host "OK: index.html, admin.html, public/index.html, public/admin.html, vercel.json, .vercelignore sudah ditulis." -ForegroundColor Green
Write-Host "Mengecek file..." -ForegroundColor Cyan
Get-Item .\index.html, .\admin.html, .\public\index.html, .\public\admin.html, .\vercel.json, .\.vercelignore | Select-Object Name, Length

Write-Host "Commit dan push ke GitHub..." -ForegroundColor Cyan
git add index.html admin.html public/index.html public/admin.html vercel.json .vercelignore
$commitResult = git commit -m "Emergency static Supabase MoodBite deployment" 2>&1
Write-Host $commitResult
if ($LASTEXITCODE -ne 0) {
    Write-Host "Commit mungkin tidak dibuat karena tidak ada perubahan. Tetap lanjut push." -ForegroundColor Yellow
}
git push origin main
Write-Host "SELESAI. Sekarang cek Vercel Deployments: harus muncul commit Emergency static Supabase MoodBite deployment." -ForegroundColor Green
