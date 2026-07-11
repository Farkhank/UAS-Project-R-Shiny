# Anova & Tukey Shiny Dashboard

Aplikasi web interaktif berbasis R Shiny dan `shinydashboard` yang dirancang untuk mempermudah analisis statistika, khususnya pengujian perbedaan rata-rata antar kelompok menggunakan **Analisis Varians (ANOVA)** dan **Uji Lanjut Tukey HSD (Honestly Significant Difference)**.

## Fitur Utama

1. **Halaman Utama (Dashboard):** Panduan ringkas alur kerja penggunaan aplikasi.
2. **Unggah & Atur Data:** 
   - Mendukung impor file data berformat `.csv`.
   - Konfigurasi delimiter (koma, titik koma, tab) dan tanda kutip secara dinamis.
   - Penentuan variabel Faktor (Kategori/X) dan variabel Respon (Numerik/Y).
   - Opsi tipe model ANOVA: **Efek Utama Saja (Aditif / +)** atau **Dengan Efek Interaksi (*)**.
   - Pratinjau (*preview*) data (*Head* atau *All*).
3. **Visualisasi Data:** Pembuatan grafik *Boxplot* otomatis menggunakan `ggplot2` untuk melihat distribusi variabel numerik berdasarkan faktor terpilih.
4. **Uji ANOVA:** Menampilkan *output* tabel ANOVA asli dari R beserta **interpretasi otomatis berbahasa Indonesia** (apakah hasil Signifikan atau Tidak Signifikan berdasarkan *p-value* < 0.05).
5. **Uji Tukey HSD:** Menampilkan *output* pengujian *post-hoc* berpasangan beserta **list otomatis pasangan kelompok yang memiliki perbedaan rata-rata signifikan**.

Sebelum menjalankan aplikasi, pastikan Anda telah menginstal *packages* R berikut:

```R
install.packages(c("shiny", "shinydashboard", "ggplot2", "dplyr"))
