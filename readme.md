# Notes 

Aplikasi pencatat (*note-taking*) mobile yang ultra-ringan, minimalis, dan berjalan penuh secara **offline**. Desain visual mengadopsi gerakan seni neoplasticism dan estetika brutalist **De Stijl**—menggunakan sudut siku murni tanpa kelengkungan, batas garis hitam tebal, bayangan solid (*hard shadows*), serta aksen warna primer.

## Fitur Utama

* **Estetika Notes**:

  * `0px border radius` di seluruh elemen UI.

  * Border solid hitam berukuran `2dp` dan offset bayangan solid (tanpa efek *blur*).

  * Skema warna primer: Primary Blue (`#0000FF`), Red (`#FF0000`), dan Yellow (`#FFFF00`) dengan kanvas putih bersih.

  * Tipografi: Helvetica/Arial untuk isi teks, JetBrains Mono untuk metadata, tanggal, dan indikator angka.

* **Instant Search**: Pencarian real-time langsung di Home Screen saat pengguna mengetik kata kunci.

* **Deep Search & Auto-Jump**:

  * Menyorot (*highlight*) kata kunci yang cocok dengan latar belakang warna kuning terang.

  * Fitur **Auto-Jump** yang melompatkan posisi *viewport/scroll* secara instan ke koordinat kata yang dicari di catatan panjang menggunakan kalkulasi `TextPainter`.

  * Dilengkapi *sticky mini-navigator* (`[ < ] 1 / 4 [ > ]`) untuk berpindah antar temuan kata berikutnya dan sebelumnya (*Next/Previous matches*).

* **Batch Management**: Mode multi-seleksi dengan cara menekan lama (*long-press*) kartu catatan pada Home Screen untuk menghapus beberapa catatan sekaligus secara massal.

* **100% Offline & Auto-Save**: Penyimpanan lokal tanpa dependensi *cloud* menggunakan Hive NoSQL database, dilengkapi sistem *auto-save* berbasis *debouncing* saat terjadi perubahan teks.

## Tech Stack

| Komponen | Pustaka / Framework | 
| ----- | ----- | 
| **Framework** | Flutter (Dart SDK) | 
| **Local Database** | `hive`, `hive_flutter` | 
| **State Management** | `provider` | 
| **Typography** | Helvetica / Arial (Content), JetBrains Mono (Metadata & Counters) | 
| **Launcher Icons** | `flutter_launcher_icons` | 

## Struktur Folder Project

```
lib/
├── models/
│   └── note.dart                   # Data model Note & adapter Hive
├── providers/
│   └── notes_provider.dart         # State management untuk operasi CRUD
├── screens/
│   ├── home_screen.dart            # List catatan, pencarian, & multi-select delete
│   └── note_detail_screen.dart     # Text editor, deep search & auto-jump navigation
├── services/
│   └── hive_service.dart           # Inisialisasi Hive box & operasi database lokal
├── theme/
│   └── destijl_theme.dart          # Konstanta warna, tipografi, border, dan shadow
└── widgets/
    ├── deep_search_controller.dart # Custom controller untuk inline text highlight
    ├── destijl_button.dart         # Komponen tombol kustom De Stijl
    └── search_mini_navigator.dart  # Widget navigator pencarian kata di editor

```

## Panduan Menjalankan Project

### Prasyarat

* Flutter SDK terinstal di komputer.

* Perangkat Android dengan mode **USB Debugging** aktif atau emulator Android.

### Langkah Instalasi

1. **Clone repository ini:**

   ```
   git clone https://github.com/username-kamu/de-stijl-notes.git
   cd de-stijl-notes
   
   ```

2. **Unduh seluruh dependensi:**

   ```
   flutter pub get
   
   ```

3. **Generate Icon Aplikasi (Opsional jika mengganti icon):**

   ```
   dart run flutter_launcher_icons
   
   ```

4. **Jalankan di mode Development:**

   ```
   flutter run
   
   ```

## Build Versi Rilis (Production APK)

Untuk menghasilkan file APK rilis yang sudah terkompilasi secara *native Ahead-Of-Time (AOT)* dengan performa maksimal dan bebas *lag*:

```
flutter build apk --release

```

File APK siap pakai akan tersedia di direktori:

```
build/app/outputs/flutter-apk/app-release.apk

```

## Lisensi

Proyek ini dirilis di bawah lisensi [MIT License](LICENSE). Bebas digunakan, dimodifikasi, dan dikembangkan kembali.
