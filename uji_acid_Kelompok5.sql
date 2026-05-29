SELECT '===== UJI 1: ATOMICITY =====' AS info;

-- Step 1: Catat baseline total stok BERAS nasional
SELECT 'SEBELUM ROLLBACK — Total stok BERAS nasional:' AS keterangan;
SELECT SUM(jumlah) AS total_stok_beras FROM inventaris_stok
WHERE id_komoditas = 'BERAS';

-- Step 2: Cek stok JB sebelum
SELECT id_wilayah, jumlah AS stok_sebelum FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

-- Step 3: Mulai transaksi, lakukan UPDATE pertama, lalu ROLLBACK
BEGIN;
    UPDATE inventaris_stok SET jumlah = jumlah - 100
    WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';
ROLLBACK;

-- Step 4: Verifikasi stok JB kembali ke semula
SELECT 'SETELAH ROLLBACK — Stok JB (harus tetap 14800):' AS keterangan;
SELECT id_wilayah, jumlah AS stok_sesudah FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

-- Step 5: Total nasional harus identik
SELECT 'SETELAH ROLLBACK — Total stok BERAS nasional (harus sama):' AS keterangan;
SELECT SUM(jumlah) AS total_stok_beras FROM inventaris_stok
WHERE id_komoditas = 'BERAS';

SELECT '===== UJI 2A: CONSISTENCY (Constraint) =====' AS info;

SELECT 'Mencoba UPDATE ke nilai negatif (harus muncul ERROR):' AS keterangan;
BEGIN;
    UPDATE inventaris_stok SET jumlah = -999
    WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';
COMMIT;

-- Verifikasi nilai tidak berubah
SELECT 'Stok JB setelah percobaan (harus tetap 15000):' AS keterangan;
SELECT id_wilayah, jumlah FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

SELECT '===== UJI 2B: CONSISTENCY (Konservasi Stok) =====' AS info;

SELECT 'Total BERAS SEBELUM transaksi distribusi:' AS keterangan;
SELECT SUM(jumlah) AS total_beras FROM inventaris_stok
WHERE id_komoditas = 'BERAS';

BEGIN;
    -- Distribusi JT ke JK: 500 kg
    UPDATE inventaris_stok SET jumlah = jumlah - 500
    WHERE id_wilayah = 'JT' AND id_komoditas = 'BERAS';
    UPDATE inventaris_stok SET jumlah = jumlah + 500
    WHERE id_wilayah = 'JK' AND id_komoditas = 'BERAS';

    -- Distribusi JI ke SN: 300 kg
    UPDATE inventaris_stok SET jumlah = jumlah - 300
    WHERE id_wilayah = 'JI' AND id_komoditas = 'BERAS';
    UPDATE inventaris_stok SET jumlah = jumlah + 300
    WHERE id_wilayah = 'SN' AND id_komoditas = 'BERAS';

    -- Distribusi JB ke BL: 200 kg
    UPDATE inventaris_stok SET jumlah = jumlah - 200
    WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';
    UPDATE inventaris_stok SET jumlah = jumlah + 200
    WHERE id_wilayah = 'BL' AND id_komoditas = 'BERAS';
COMMIT;

SELECT 'Total BERAS SESUDAH transaksi (harus sama dengan sebelumnya):' AS keterangan;
SELECT SUM(jumlah) AS total_beras FROM inventaris_stok
WHERE id_komoditas = 'BERAS';

SELECT '===== UJI 3: ISOLATION — PANDUAN DUA TERMINAL =====' AS info;

-- Reset stok JB ke 15000 sebelum uji isolation
UPDATE inventaris_stok SET jumlah = 15000
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

SELECT 'Stok JB sudah direset ke 15000. Siap untuk uji isolation.' AS status;
SELECT 'Buka dua terminal psql dan ikuti panduan uji_isolation_terminal1.sql dan uji_isolation_terminal2.sql' AS petunjuk;

SELECT '===== UJI 4: DURABILITY =====' AS info;

-- Step 1: Commit transaksi dengan id unik
BEGIN;
    INSERT INTO transaksi_distribusi VALUES (
        'TRX-TEST-DURABILITY',
        'JB', 'JK', 'BERAS', 777,
        'SELESAI', NOW(),
        'Data uji Durability — harus tetap ada setelah restart PostgreSQL'
    );
COMMIT;

-- Step 2: Verifikasi data ada sebelum restart
SELECT 'Data SEBELUM restart (harus ada 1 baris):' AS keterangan;
SELECT id_transaksi, jumlah_distribusi, keterangan
FROM transaksi_distribusi
WHERE id_transaksi = 'TRX-TEST-DURABILITY';

SELECT 'SEKARANG: Buka terminal WSL2 baru, jalankan:' AS langkah;
SELECT '  sudo service postgresql stop && sudo service postgresql start' AS perintah;
SELECT 'Setelah restart, jalankan file: uji_durability_verifikasi.sql' AS lanjutan;
