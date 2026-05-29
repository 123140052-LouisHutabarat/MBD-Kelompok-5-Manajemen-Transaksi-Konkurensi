-- ============================================================
-- UJI ISOLATION — TERMINAL 1
-- Jalankan di terminal psql PERTAMA
-- ============================================================

-- TAHAP 1: Dirty Read Test
-- Jalankan ini, lalu SEGERA pindah ke Terminal 2
-- JANGAN ketik apapun lagi sampai diberi tahu

SELECT '=== TERMINAL 1: Mulai transaksi (belum commit) ===' AS info;

BEGIN;
UPDATE inventaris_stok
SET jumlah = 99999
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

-- BERHENTI DI SINI
-- Pindah ke Terminal 2, jalankan SELECT di sana
-- Setelah Terminal 2 selesai, kembali ke sini dan jalankan ROLLBACK

-- [Setelah Terminal 2 selesai membaca]
ROLLBACK;

SELECT 'Terminal 1: Rollback selesai. Stok JB kembali ke:' AS info;
SELECT jumlah FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';


-- TAHAP 2: Lost Update Test
SELECT '=== TERMINAL 1: Lost Update Test ===' AS info;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT jumlah AS stok_JB_dibaca_T1
FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

-- BERHENTI DI SINI
-- Pindah ke Terminal 2, biarkan T2 UPDATE dan COMMIT dulu
-- Setelah T2 COMMIT, kembali sini dan lanjutkan

UPDATE inventaris_stok
SET jumlah = jumlah - 100
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

COMMIT;
-- Harus ERROR: could not serialize access due to concurrent update
-- Ini BENAR, berarti Lost Update berhasil dicegah
