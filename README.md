# CinePick

CinePick adalah aplikasi mobile berbasis Flutter yang digunakan untuk mencari dan menjelajahi informasi film. Aplikasi ini memanfaatkan TMDB API untuk mengambil data film dan menampilkannya kepada pengguna.

## Fitur Utama

- Menampilkan daftar film populer.
- Mencari film berdasarkan judul.
- Menjelajahi film berdasarkan genre.
- Menampilkan detail film, termasuk sinopsis, rating, tanggal rilis, dan genre.
- Menampilkan daftar pemeran film.
- Menampilkan rekomendasi film serupa.
- Menyimpan dan menghapus film favorit.

## Teknologi dan Package

- **Flutter** — framework untuk pengembangan aplikasi mobile.
- **Dart** — bahasa pemrograman aplikasi.
- **TMDB API** — sumber data informasi film.
- **http** — mengirim permintaan HTTP ke API.
- **shared_preferences** — menyimpan daftar film favorit secara lokal.
- **cupertino_icons** — menyediakan ikon bergaya iOS.

## Struktur Project

- `lib/main.dart` — titik awal aplikasi.
- `lib/movie.dart` — model data film.
- `lib/movie_service.dart` — layanan pengambilan data dari TMDB API.
- `lib/cast_member.dart` — model data pemeran.
- `lib/pages/` — halaman utama, pencarian, detail film, dan favorit.
- `lib/services/` — pengelolaan penyimpanan film favorit.
- `lib/widgets/` — komponen antarmuka yang digunakan kembali.

## Persyaratan

- Flutter SDK dan Dart SDK.
- Visual Studio Code atau editor lain yang mendukung Flutter.
- Koneksi internet.
- TMDB API key yang valid.

## Cara Menjalankan Aplikasi

1. Unduh atau clone repository ini.
2. Buka folder project melalui terminal atau Visual Studio Code.
3. Jalankan perintah berikut untuk mengunduh package:

   ```bash
   flutter pub get
   ```

4. Konfigurasikan TMDB API key sesuai pengaturan pada source code.
5. Jalankan aplikasi menggunakan emulator atau perangkat yang terhubung:

   ```bash
   flutter run
   ```

## Sumber Data

Data film diperoleh melalui [TMDB API](https://developer.themoviedb.org/docs).