-- ============================================================
-- UJI DURABILITY — VERIFIKASI SETELAH RESTART
-- Jalankan ini SETELAH PostgreSQL direstart
-- Sambungkan dengan: psql -U postgres
-- ============================================================

SELECT '=== UJI DURABILITY: Verifikasi setelah restart ===' AS info;

SELECT id_transaksi, id_wilayah_asal, id_wilayah_tujuan,
       jumlah_distribusi, keterangan, timestamp_transaksi
FROM transaksi_distribusi
WHERE id_transaksi = 'TRX-TEST-DURABILITY';

-- Jika data masih ada (1 baris) = DURABILITY TERJAMIN
-- Jika data tidak ada (0 baris) = DURABILITY GAGAL (tidak akan terjadi di PostgreSQL)

SELECT 'Jika muncul 1 baris di atas, DURABILITY PostgreSQL TERJAMIN via WAL' AS kesimpulan;
