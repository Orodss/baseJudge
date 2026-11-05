# baseJudge

Backend competitive programming berbasis Go dan Fiber. Panduan ini menjelaskan
setup dan alur pengembangan lokal. Saat ini tersedia server HTTP dasar, enum
domain, dan 20 tabel database dalam 13 unit migrasi. Autentikasi, koneksi API ke
database, logika kontes, dan eksekusi judge belum diimplementasikan.

## 1. Instal prasyarat

| Perangkat | Kebutuhan | Instalasi |
| --- | --- | --- |
| Git | Clone dan kontribusi | [Unduh Git](https://git-scm.com/downloads) |
| Go | 1.26.0 sesuai go.mod | [Instalasi](https://go.dev/doc/install), [rilis Go](https://go.dev/dl/) |
| Docker + Compose | Linux containers; Compose 2.24.4+ | [Instalasi Compose](https://docs.docker.com/compose/install/) |
| PowerShell | Runner tes database | Windows PowerShell atau [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell) untuk Linux/macOS |

Windows: gunakan Docker Desktop dengan WSL 2 dan Linux containers. Docker Desktop
sudah menyertakan Compose. Linux: gunakan Docker Engine dengan Compose plugin.
Buka terminal baru setelah instalasi agar PATH diperbarui. Pastikan Docker engine aktif:

```sh
git --version
go version
docker version
docker compose version
```

PostgreSQL dan golang-migrate tidak perlu diinstal di host untuk setup awal.
Compose memakai image `postgres:18.6-bookworm` dan `migrate/migrate:v4.19.1`.
Fiber dan dependensi Go diambil melalui Go modules. Node.js/npm hanya diperlukan
untuk mengerjakan [dokumentasi DBML](documentation/readme.md).

## 2. Clone dan instal dependensi proyek

Jalankan di PowerShell atau Bash:

```sh
git clone https://github.com/Orodss/baseJudge.git
cd baseJudge
go mod download
```

Ikuti versi dalam `go.mod` dan `go.sum`; jangan memperbarui seluruh dependensi
hanya untuk setup lokal.

## 3. Konfigurasi environment

Buat `.env` dari template pada setup pertama. Jangan menimpa konfigurasi lama.

**PowerShell:**

```powershell
if (-not (Test-Path -LiteralPath .env)) {
    Copy-Item .env.example .env
}
```

**Bash:**

```bash
if [ ! -e .env ]; then
  cp .env.example .env
fi
```

Edit `.env` melalui editor. Isi password acak berbentuk hexadecimal; placeholder
berikut harus diganti sebelum menjalankan Compose:

```dotenv
POSTGRES_USER=basejudge
POSTGRES_PASSWORD=<isi-password-hex-acak>
POSTGRES_DB=basejudge
POSTGRES_PORT=55432
```

Password harus URL-safe karena migrasi menggunakan URL koneksi PostgreSQL.
Jangan commit `.env` atau membagikan konfigurasi yang berisi kredensial.
`.env.example` hanya menyimpan template tanpa rahasia.

## 4. Jalankan database dan migrasi

Dari root repository, dengan Docker aktif:

```sh
docker compose up -d --wait postgres
docker compose run --rm migrate up
docker compose run --rm migrate version
docker compose ps
```

Versi schema saat ini adalah **13**, tanpa status dirty: 20 tabel aplikasi,
144 kolom, dan 42 foreign key. Tabel internal `schema_migrations` tidak termasuk
hitungan tersebut. Migrasi berjalan secara eksplisit, bukan saat API menyala.

| Koneksi | Alamat default |
| --- | --- |
| Dari host / database client | `127.0.0.1:55432` |
| Dari service Compose | `postgres:5432` |
| Database dan user | `basejudge`, dapat diubah di .env |

Data tersimpan di named volume pada `/var/lib/postgresql`. Pertahankan nama project
Compose saat memakai ulang data. Jika folder clone berbeda dan ingin menggunakan
project `basejudge` yang sudah ada, gunakan `docker compose -p basejudge` secara
konsisten pada perintah Compose.

## 5. Jalankan server

Server Go berjalan di host; container API belum tersedia. Buka terminal terpisah:

```sh
go run ./cmd
```

Server mendengarkan pada port `8080`. Periksa health endpoint:

**PowerShell:**

```powershell
Invoke-WebRequest http://localhost:8080/health
```

**Bash:**

```bash
curl -i http://localhost:8080/health
```

Hasil yang diharapkan: HTTP `200` dengan body `ok`. Endpoint scaffold lainnya:
`/` dan `/v1/api/`. Health check hanya memeriksa server HTTP, belum koneksi database.
Hentikan server dengan `Ctrl+C`.

## 6. Alur kerja harian

| Kegiatan | Perintah |
| --- | --- |
| Nyalakan database | `docker compose up -d --wait postgres` |
| Terapkan migrasi baru | `docker compose run --rm migrate up` |
| Lihat versi schema | `docker compose run --rm migrate version` |
| Lihat log database | `docker compose logs --tail=100 postgres` |
| Jalankan API | `go run ./cmd` |
| Hentikan database dan pertahankan data | `docker compose stop` |

`docker compose down --volumes` menghapus volume database; jangan gunakan untuk
shutdown harian. Mengubah password dalam `.env` tidak mengubah kredensial database
yang sudah diinisialisasi. Volume adalah penyimpanan persisten, bukan backup.

## 7. Pemeriksaan dan tes

Jalankan dari root repository:

```sh
go test ./...
go vet ./...
go build ./...
```

Untuk perubahan schema/migrasi/Compose, jalankan tes database dengan Docker aktif.

**Windows PowerShell:**

```powershell
powershell -NoProfile -File test/db/test.ps1
```

**PowerShell 7, termasuk dari Bash di Linux/macOS:**

```sh
pwsh -NoProfile -File test/db/test.ps1
```

Runner memakai project Compose acak, kredensial sementara, tmpfs, dan tanpa host
port. Tes mencakup upgrade dengan mempertahankan user, rollback/reapply, full
down/up, constraint, dan rollback transaksi. Pembersihan hanya menghapus project
tes tersebut, bukan database pengembangan.

## 8. Menambah migrasi

File migrasi ada di `db/migrations/`. Jangan mengubah migrasi yang sudah diterapkan;
tambahkan pasangan up/down dengan nomor berikutnya.

CLI lokal opsional dapat diinstal mengikuti
[panduan golang-migrate](https://github.com/golang-migrate/migrate/blob/master/cmd/migrate/README.md):

```sh
go install -tags postgres github.com/golang-migrate/migrate/v4/cmd/migrate@v4.19.1
migrate create -ext sql -dir db/migrations -seq describe_change
```

Jika `migrate` belum ditemukan, tambahkan direktori `GOBIN` ke PATH, atau
`GOPATH/bin` bila GOBIN kosong. Periksa dengan `go env GOBIN GOPATH`.
Instalasi tool ini tidak menambah dependensi aplikasi ke go.mod.

Tambahkan tes valid/invalid, foreign key, dan rollback. Perbarui
[schema DBML](documentation/database.dbml) dan [panduan database](documentation/readme.md)
bersamaan dengan migrasi. Uji down migration hanya pada database disposable.

## Struktur repository

```text
cmd/                    Entry point server
domain/enums/           Enum domain dan tes
internal/infra/server/  Server HTTP Fiber
db/migrations/          Migrasi PostgreSQL up/down
test/db/                Tes database disposable
test/infra/server/      Tes HTTP
documentation/          Schema DBML dan panduan database
compose.yaml            PostgreSQL dan tool migrasi
```

## Pemecahan masalah

- **Docker tidak terhubung:** nyalakan Docker Desktop/Engine dan gunakan Linux containers. Buka ulang terminal jika baru menginstalnya.
- **Port 55432 terpakai:** ubah POSTGRES_PORT di .env, lalu jalankan ulang `docker compose up -d --wait postgres`.
- **Port 8080 terpakai:** hentikan proses yang memakainya. Port API ditetapkan di cmd/main.go, belum melalui .env.
- **Migrasi dirty:** baca error dan periksa schema; jangan otomatis memakai force, rollback, atau menghapus volume pada data yang disimpan.
- **Go cache tidak dapat ditulis di Windows:** atur `$env:GOCACHE = Join-Path $env:TEMP 'basejudge-go-cache'` untuk sesi tersebut, lalu ulangi pemeriksaan. Ini tidak mengubah konfigurasi global dan tidak memperbaiki masalah izin module cache yang terpisah.

## Berkontribusi

Ikuti [CONTRIBUTING.md](CONTRIBUTING.md) untuk alur branch pribadi → PR ke `main`,
pemeriksaan sebelum PR, dan format commit. Detail penulisan kode ada di
[CONVENTION.md](CONVENTION.md).
