# 🌾 Evaluasi Kepatuhan ACID pada Transaksi Terdistribusi untuk Sistem Rantai Pasok Pangan Multi-Regional

> **Mata Kuliah:** IF25-40405 — Manajemen Basis Data | Semester Genap 2025/2026  
> **Kelompok 5** | Institut Teknologi Sumatera (ITERA)  
> 📁 **Google Drive Proyek:** [Akses Laporan, Presentasi & Video Demo](https://link-google-drive-anda-di-sini)

---

## 📋 Deskripsi Proyek

Proyek ini mengimplementasikan dan mengevaluasi kepatuhan prinsip **ACID** (Atomicity, Consistency, Isolation, Durability) pada sistem basis data terdistribusi berbasis **PostgreSQL + Citus** untuk mensimulasikan sistem rantai pasok pangan multi-regional di Indonesia.

Sistem dirancang tanpa koordinator pusat (*single point of failure*) menggunakan arsitektur **cloud-native peer-to-peer**, dilengkapi mekanisme **Multi-Version Concurrency Control (MVCC)** dan **Two-Phase Ordering** untuk menjaga konsistensi data stok dan harga komoditas pangan dari berbagai wilayah secara konkuren.

---

## 👥 Anggota Kelompok

| Nama | NIM | Kontribusi |
|---|---|---|
| Louis Hutabarat | 123140052 | Latar Belakang, Rumusan Masalah, Tujuan Penelitian |
| Bayu Brigas Novaldi | 123140072 | Metodologi: Strategi Optimasi & Metode Evaluasi |
| Faiz Akbar Al Kalabadzi | 123140091 | Kajian Literatur (Blockchain, Smart Contract, SQL vs NoSQL) |
| Abel Fortino | 123140111 | Research Gap & Posisi Penelitian |
| M. Hafizurrahman Akbar | 123140123 | Metodologi: Arsitektur Sistem & Desain Skema |
| Jordy Anugrah Akbar | 123140141 | Kajian Literatur (MVCC & Protokol Komit Terdistribusi) |
| Martino Kelvin | 123140165 | Desain Eksperimen & Hasil yang Diharapkan |
| Nadya Shafwah Yusuf | 123140167 | Kesimpulan, Saran & Daftar Pustaka |

---

## 🗂️ Struktur Repositori

```
MBD-Kelompok-5-Manajemen-Transaksi-Konkurensi/
│
├── setup_dummy_data_Kelompok5.sql          # Inisialisasi skema dan data dummy
├── uji_acid_Kelompok5.sql                  # Skrip pengujian ACID (Atomicity, Consistency, Durability)
├── uji_isolation_terminal1_Kelompok5.sql   # Skrip uji Isolation — sesi terminal 1
├── uji_isolation_terminal2_Kelompok5.sql   # Skrip uji Isolation — sesi terminal 2
├── uji_durability_verifikasi_Kelompok5.sql # Verifikasi Durability pasca-restart
│
├── Hasil Skenario Pengujian/
│   ├── HASIL PENGUJIAN ATOMICITY.png
│   ├── HASIL PENGUJIAN CONSISTENCY.png
│   ├── HASIL PENGUJIAN ISOLATION.png
│   ├── HASIL PENGUJIAN DURABILITY.png
│   └── MEMASUKKAN DATABASE DUMMY.png
│
└── Hasil Benchmark dengan Pgbench/
    ├── Baseline_Testing 10 Client.png
    ├── Baseline_Testing 50 Client.png
    ├── Baseline_Testing 80 Client.png
    ├── Serializable_Testing 10 Client.png
    ├── Serializable_Testing 50 Client.png
    └── Serializable_Testing 80 Client.png
```

---

## 🛠️ Teknologi & Environment

| Komponen | Spesifikasi |
|---|---|
| **Database** | PostgreSQL + ekstensi Citus |
| **Sistem Operasi** | Windows 11 dengan WSL2 |
| **Bahasa** | SQL |
| **Benchmark Tools** | pgbench (bawaan PostgreSQL), Docker Compose |
| **Jumlah Node Simulasi** | 1 Koordinator + 2–3 Worker Node (Citus) |

---

## ⚙️ Cara Menjalankan

### Prasyarat

- WSL2 aktif di Windows 11
- PostgreSQL terinstal di dalam WSL2
- (Opsional) Docker + Docker Compose untuk mode multi-node Citus

### Langkah 1 — Inisialisasi Database

Jalankan skrip setup untuk membuat skema tabel dan mengisi data dummy:

```bash
psql -U postgres -f setup_dummy_data_Kelompok5.sql
```

Skrip ini akan membuat empat tabel utama:
- `region` — data wilayah distribusi (JB, JT, JK, JI, SN, BL, dll.)
- `produk_pangan` — daftar komoditas (BERAS, JAGUNG, KEDELAI, dll.)
- `inventaris_stok` — stok komoditas per wilayah, dengan constraint `CHECK (jumlah >= 0)`
- `transaksi_distribusi` — riwayat pergerakan komoditas antar wilayah

### Langkah 2 — Jalankan Pengujian ACID

```bash
psql -U postgres -f uji_acid_Kelompok5.sql
```

File ini mencakup pengujian untuk **Atomicity**, **Consistency**, dan **Durability** secara berurutan.

### Langkah 3 — Uji Isolation (Dua Terminal)

Buka **dua terminal psql** secara bersamaan:

**Terminal 1:**
```bash
psql -U postgres -f uji_isolation_terminal1_Kelompok5.sql
```

**Terminal 2:**
```bash
psql -U postgres -f uji_isolation_terminal2_Kelompok5.sql
```

> Ikuti urutan eksekusi sesuai komentar di dalam masing-masing file untuk mensimulasikan concurrent access antar dua node regional.

### Langkah 4 — Verifikasi Durability Pasca-Restart

Setelah menjalankan uji Durability, restart PostgreSQL secara paksa:

```bash
sudo service postgresql stop && sudo service postgresql start
```

Kemudian verifikasi data tetap ada:

```bash
psql -U postgres -f uji_durability_verifikasi_Kelompok5.sql
```

---

## 🧪 Skenario Pengujian ACID

### Skenario 1 — Atomicity
Transaksi distribusi beras dari Node `JB` ke Node `JT` dieksekusi dalam blok `BEGIN...COMMIT`. Di tengah transaksi, dilakukan injeksi kegagalan berupa `ROLLBACK` paksa. Sistem diverifikasi tidak menyimpan perubahan parsial — total stok nasional harus identik sebelum dan sesudah kegagalan.

### Skenario 2 — Consistency
Constraint `CHECK (jumlah >= 0)` didefinisikan pada tabel `inventaris_stok`. Percobaan `UPDATE` yang menghasilkan nilai negatif dilakukan — sistem harus menolak transaksi secara otomatis. Total stok nasional juga diverifikasi tetap konservatif setelah serangkaian distribusi antar wilayah.

### Skenario 3 — Isolation
Dua sesi psql dibuka secara bersamaan mensimulasikan dua node regional berbeda. Dengan isolation level `SERIALIZABLE`:
- Sesi kedua tidak boleh membaca data uncommitted dari sesi pertama (no dirty read).
- Ketika dua sesi mencoba UPDATE baris yang sama secara bersamaan, salah satu harus gagal dengan serialization error (no lost update).

### Skenario 4 — Durability
Transaksi di-commit ke database. PostgreSQL kemudian dihentikan secara paksa (`kill -9`). Setelah restart, data yang telah di-commit diverifikasi masih tersedia berkat mekanisme **Write-Ahead Log (WAL)**.

---

## 📊 Metrik Evaluasi

| Metrik | Deskripsi | Target |
|---|---|---|
| **Atomicity Rate** | % transaksi rollback sempurna tanpa partial write | 100% |
| **Constraint Violation Detection Rate** | % percobaan pelanggaran constraint yang ditolak | 100% |
| **Dirty Read Rate** | Jumlah kasus data uncommitted terbaca sesi lain | 0 kasus |
| **Lost Update Rate** | Jumlah kasus dua UPDATE konkuren sama-sama berhasil tanpa error | 0 kasus |
| **Abort Rate** | % transaksi di-abort akibat serialization conflict (diukur pada 10, 50, 80 concurrent clients) | Diukur |
| **Throughput** | Transaksi per detik (TPS) via pgbench | Diukur |
| **Latency** | Rata-rata waktu respons per transaksi (ms) | Diukur |
| **Recovery Time** | Waktu PostgreSQL pulih dari crash via WAL | < 30 detik |

---

## 📈 Hasil yang Diharapkan

| Properti | Konfigurasi Baseline (READ COMMITTED) | Konfigurasi Proposed (SERIALIZABLE) | Target |
|---|---|---|---|
| Atomicity Rate | 100% | 100% | 100% |
| Constraint Violation Detection | 100% | 100% | 100% |
| Dirty Read Rate | > 0 kasus | 0 kasus | 0 kasus |
| Lost Update Rate | > 0 kasus | 0 kasus | 0 kasus |
| Recovery Rate | 100% | 100% | 100% |
| Abort Rate (80 clients) | ~5% | ~25–35% | Diukur |

> **Trade-off:** Konfigurasi SERIALIZABLE mengorbankan sebagian throughput dan meningkatkan abort rate pada skenario konkurensi tinggi, sebagai harga dari jaminan konsistensi data yang penuh.

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────────────────────┐
│              Decentralized Coordination Layer        │
│               (Two-Phase Ordering / 2PO)             │
└─────────────┬──────────────┬───────────┬─────────────┘
              │              │           │
    ┌─────────▼──┐   ┌───────▼──┐   ┌───▼──────┐
    │  Node JB   │   │  Node JT │   │  Node SN │  ...
    │ (Jawa Brt) │   │(Jawa Tgh)│   │(Sumatera)│
    └─────────┬──┘   └───────┬──┘   └───┬──────┘
              └──────────────▼──────────┘
                   ┌──────────────────┐
                   │  Storage Layer   │
                   │   (MVCC + WAL)   │
                   │  PostgreSQL+Citus│
                   └──────────────────┘
```

**Komponen Utama:**
- **Regional Data Nodes** — Simpul terdistribusi di berbagai wilayah yang menerima dan memproses data logistik lokal.
- **Decentralized Coordination Layer** — Mengatur urutan eksekusi transaksi menggunakan Two-Phase Ordering tanpa koordinator pusat.
- **Storage & Concurrency Layer** — Implementasi MVCC terdistribusi untuk concurrent writes tanpa latensi locking berlebihan.

---

## 🔗 Tautan Google Drive

Seluruh dokumentasi proyek, laporan komprehensif, slide presentasi, serta video demo aplikasi dapat diakses melalui tautan di bawah ini:
👉 [**Google Drive Kelompok 5 — Manajemen Transaksi Konkurensi**](https://link-google-drive-anda-di-sini)

---

## 📚 Referensi Utama

- Freitag & Kemper. *Memory-Optimized MVCC for Disk-Based Database Systems.* TU München, 2025.
- Psarakis et al. *Transactional Cloud Applications with ACID Serializability (Styx).* 2025.
- Zhu et al. *Decentralized Concurrency Control Protocol (MVSG).* 2024.
- Gbaranwi & Asagba. *Distributed Transactions and Distributed Concurrency Control.* IJCSMC, 2021.
- Daraghmi et al. *Smart Contracts for Agricultural Supply Chain Management.* IEEE Access, 2024.
- Khan et al. *SQL and NoSQL Performance Analysis — Systematic Literature Review.* Big Data and Cognitive Computing, 2023.
