# APLIKASI ANOVA AND TUKEY APP BY ALLSTAR STATS

Aplikasi web interaktif ini dibuat menggunakan **R Shiny** dan **shinydashboard**. Tujuannya adalah untuk mempermudah analisis data statistik, khususnya untuk melihat perbedaan rata-rata antar kelompok lewat **Uji ANOVA** dan uji lanjut **Tukey HSD (Honestly Significant Difference)** secara otomatis dan cepat.

### Informasi Project
* **Project:** Tugas Akhir / UAS Komputasi Statistika
* **Dosen Pengampu:** Faroh Ladayya, M.Si.
* **Kelompok:** Allstar Kelompok

**Anggota Kelompok:**
1. Muhamad Praditya Setyawan (1314624012)
2. Muhammad Farkhanudin (1314624015)
3. Alpin Syah Hasibuan (1314624019)
4. M Danish Maulid Jayanegara (1314624055)
5. Hanif Anggoro (1314624070)
6. Rey Surya Ramadhan (1314624071)

## Fitur Utama Aplikasi

1. **Halaman Utama (Home Dashboard)**
   * Tampilan *welcome screen* yang bersih dan *user-friendly*, lengkap dengan panduan singkat (alur 1-2-3) cara menggunakan aplikasi.

2. **Unggah & Atur Data (Upload Data)**
   * **Import File:** Bisa langsung *upload* file `.csv` dari komputer Anda.
   * **Custom Settings:** Bebas atur pemisah data (*separator* seperti koma, titik koma, atau tab) dan tanda kutip (*quote*).
   * **Mapping Variabel:** Tinggal pilih kolom mana yang jadi **Variabel Faktor (Kategori/X)** dan kolom mana yang jadi **Variabel Respon (Numerik/Y)** lewat menu *dropdown*.
   * **Fleksibilitas Model:** Mendukung analisis untuk lebih dari satu variabel X, lengkap dengan pilihan tipe model **Efek Utama Saja (+)** atau **Dengan Efek Interaksi (*)**.
   * **Data Preview:** Cek isi file langsung di aplikasi (bisa intip beberapa baris teratas saja atau semua data).

3. **Visualisasi Data**
   * Otomatis membuat grafik **Boxplot** yang rapi menggunakan `ggplot2`. Grafik ini langsung memetakan distribusi data numerik berdasarkan kategori yang Anda pilih untuk mendeteksi sebaran dan *outlier* (pencilan) dengan mudah.

4. **Uji ANOVA**
   * Menampilkan hasil kalkulasi tabel ANOVA asli dari sistem R.
   * Dilengkapi fitur **Interpretasi Otomatis**, jadi aplikasi langsung menjelaskan apakah hasilnya **SIGNIFIKAN** atau **TIDAK SIGNIFIKAN** berdasarkan aturan *p-value* < 0.05 tanpa perlu Anda hitung manual.

5. **Uji Tukey HSD (Post-Hoc Test)**
   * Menampilkan hasil perbandingan berpasangan (*pairwise comparison*) pasca-ANOVA.
   * Dilengkapi rangkuman otomatis yang langsung memunculkan **list pasangan kelompok mana saja yang terbukti berbeda signifikan** (nilai *p-adj* < 0.05).

Sebelum menjalankan aplikasi di, pastikan sudah menginstal  library R (*packages*) berikut. Silakan *copy-paste* perintah ini ke RStudio:

```R
install.packages(c("shiny", "shinydashboard", "ggplot2", "dplyr"))
