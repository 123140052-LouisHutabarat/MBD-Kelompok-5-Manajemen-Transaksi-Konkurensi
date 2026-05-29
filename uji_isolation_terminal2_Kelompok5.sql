-- ============================================================
-- UJI ISOLATION — TERMINAL 2
-- Jalankan di terminal psql KEDUA
-- ============================================================

-- TAHAP 1: Dirty Read Test
-- Jalankan ini SAAT Terminal 1 sedang menunggu (sudah UPDATE, belum COMMIT)

SELECT '=== TERMINAL 2: Membaca stok JB saat T1 belum commit ===' AS info;

SELECT jumlah AS stok_JB_dibaca_terminal2
FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';
-- Harus dapat: 15000 (bukan 99999)
-- Jika dapat 15000 = dirty read TIDAK terjadi = ISOLATION TERJAMIN

SELECT 'Jika hasil di atas 15000 (bukan 99999), dirty read berhasil dicegah' AS kesimpulan;

-- Sekarang kembali ke Terminal 1 dan jalankan ROLLBACK


-- TAHAP 2: Lost Update Test
-- Jalankan ini SETELAH Terminal 1 sudah SELECT tapi belum UPDATE

SELECT '=== TERMINAL 2: Lost Update Test ===' AS info;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT jumlah AS stok_JB_dibaca_T2
FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';
-- Harus dapat: 15000

UPDATE inventaris_stok
SET jumlah = jumlah - 200
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

COMMIT;
-- Terminal 2 berhasil COMMIT (stok JB menjadi 14800)

SELECT 'Terminal 2 COMMIT berhasil. Stok JB sekarang:' AS info;
SELECT jumlah FROM inventaris_stok
WHERE id_wilayah = 'JB' AND id_komoditas = 'BERAS';

-- Sekarang kembali ke Terminal 1 dan coba COMMIT di sana
-- Terminal 1 harus mendapat ERROR serialization failure
