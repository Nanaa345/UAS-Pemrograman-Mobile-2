# 📝 LisNotes

**LisNotes** adalah aplikasi manajemen catatan berbasis Android yang dibangun menggunakan **Flutter**. Aplikasi ini dirancang dengan pendekatan minimalis, memungkinkan pengguna untuk mencatat, menyimpan, dan mengelola ide mereka dengan cepat dan aman secara offline.

---

## 🚀 Fitur Utama

* **Create & Read**: Membuat catatan baru dan melihatnya catatan.
* **Update (Edit)**: Mengedit judul atau isi catatan yang sudah ada.
* **Delete**: Menghapus catatan yang tidak lagi dibutuhkan.
* **Local Persistence**: Data tersimpan secara permanen di perangkat menggunakan **SQLite**.
* **Timestamps**: Melacak waktu pembuatan dan perubahan terakhir setiap catatan.

---

## 🛠 Teknologi yang Digunakan

* **Bahasa:** [Dart](https://dart.dev/)
* **Framework:** [Flutter](https://flutter.dev/)
* **Database:** [SQFlite](https://pub.dev/packages/sqflite) (SQLite untuk Flutter)
* **Architecture:** Separation of Concerns (Pemisahan logika UI di `main.dart` dan logika data di `database_helper.dart`).

---

## ⚙️ Cara Menjalankan Project


1.  **Clone repositori ini** (atau download zip):
    ```bash
    git clone [https://github.com/username-anda/simple-blue-notes.git](https://github.com/username-anda/simple-blue-notes.git)
    ```

2.  **Masuk ke direktori project:**
    ```bash
    cd simple_blue_notes
    ```

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Jalankan aplikasi (Debug Mode):**
    Pastikan emulator Android sudah berjalan atau HP terhubung.
    ```bash
    flutter run
    ```

---

## 📦 Cara Build APK (Rilis)

Untuk menghasilkan file APK yang siap diinstal di HP Android dengan ukuran yang optimal (~15MB):

```bash
flutter build apk --release --split-per-abi