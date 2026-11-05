# Panduan kontribusi

Mulai dari [panduan pengembangan](readme.md), lalu baca
[konvensi kode](CONVENTION.md).

## Alur branch dan pull request

Gunakan branch pribadi bernama nickname, lalu ajukan pull request ke `main`.
Maintainer meninjau dan menggabungkan PR setelah pemeriksaan lulus.
Jangan push langsung ke `main` kecuali ada arahan eksplisit dari maintainer.

Jika mempunyai akses tulis ke repository:

```sh
git switch main
git pull --ff-only origin main
git switch -c nickname
```

Ganti `nickname` dengan nama branch pribadi. Jika branch sudah ada, gunakan
`git switch nickname`. Mulai dengan working tree bersih; jangan menimpa perubahan
yang belum disimpan.

Jika tidak memiliki akses tulis, fork repository di GitHub dan clone fork tersebut.
Tambahkan repository utama sebagai upstream:

```sh
git remote add upstream https://github.com/Orodss/baseJudge.git
git fetch upstream
git switch -c nickname upstream/main
```

Pada alur fork, push ke `origin` milik Anda dan buka PR dari branch tersebut ke
`Orodss/baseJudge:main`.

## Menyiapkan perubahan

- Batasi setiap PR pada satu tujuan yang dapat ditinjau. Diskusikan perubahan besar dengan maintainer terlebih dahulu.
- Ikuti struktur dan pola kode yang sudah ada. Beberapa contoh arsitektur dalam CONVENTION.md merupakan pedoman fitur mendatang, bukan paket yang sudah tersedia.
- Format file Go yang diubah dengan `gofmt`; hindari perubahan format pada file lain.
- Tambahkan tes bermakna untuk perubahan perilaku, termasuk kegagalan dan kasus batas.
- Jangan memasukkan password, token, .env, data submission, atau hidden tests ke Git maupun log.
- Perbarui dokumentasi jika setup, API, atau schema berubah.

## Perubahan database

Migrasi SQL adalah sumber kebenaran schema. Jangan mengedit migrasi yang sudah
diterapkan. Tambahkan pasangan up/down berurutan, pertahankan ID enum, dan uji
constraint serta dependensinya. Instruksi pembuatan migrasi tersedia di README.

Perbarui `documentation/database.dbml` dan dokumentasi terkait bersama migrasinya.
Jelaskan dampak data dan risiko rollback di PR. Gunakan runner disposable;
jangan menjalankan rollback pada database pengembangan yang menyimpan data.
Tes schema tidak menggantikan tes otorisasi atau transaksi aplikasi.

## Pemeriksaan sebelum PR

Untuk perubahan Go, jalankan dari root repository:

```sh
go test ./...
go vet ./...
go build ./...
git diff --check
```

Untuk perubahan database/Compose, jalankan juga:

```powershell
powershell -NoProfile -File test/db/test.ps1
```

Gunakan `pwsh` sebagai pengganti `powershell` jika memakai PowerShell 7 di
Linux/macOS. Docker harus aktif. Untuk perubahan dokumentasi saja, periksa
tautan, contoh perintah, dan konsistensi informasi; tes aplikasi tidak perlu
dijalankan ulang tanpa perubahan perilaku.

Jika mengubah DBML, ikuti validasi di [panduan database](documentation/readme.md).
Laporkan pemeriksaan yang gagal atau tidak dapat dijalankan.

## Format commit

Gunakan Conventional Commits sesuai CONVENTION.md:

```text
<type>(scope opsional): <deskripsi>
```

Contoh:

```text
feat(db): add contest registration constraints
fix(server): handle invalid request parameters
test(db): cover cross-version judging results
docs: clarify local development setup
```

Gunakan deskripsi imperatif, huruf kecil, tanpa titik di akhir. Pisahkan perubahan
yang berbeda tujuan menjadi commit terpisah. Jelaskan perubahan yang memutus
kompatibilitas dengan `BREAKING CHANGE:` pada body commit.

Tinjau dan stage hanya file terkait:

```sh
git status --short
git diff
git add readme.md CONTRIBUTING.md
git diff --cached
git commit -m "docs: clarify development and contribution guides"
git push -u origin nickname
```

Daftar file pada `git add` adalah contoh; sesuaikan dengan perubahan Anda.

## Isi pull request

PR ditujukan ke `main` dan memuat:

- Masalah atau kebutuhan yang diselesaikan, beserta issue terkait bila ada.
- Perilaku atau dokumentasi yang berubah dan alasannya.
- Tes/pemeriksaan yang dijalankan serta hasilnya.
- Dampak migrasi, perubahan kompatibilitas, dan keterbatasan yang tersisa.

Tanggapi review di branch yang sama. Penggabungan dilakukan maintainer.
