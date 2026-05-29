-- ============================================================
-- SETUP DATABASE & DATA DUMMY
-- Sistem Rantai Pasok Pangan Multi-Regional
-- Kelompok 5 - Manajemen Basis Data ITERA 2026
-- ============================================================
-- Cara menjalankan di WSL2:
--   psql -U postgres -f setup_dummy_data_Kelompok5.sql
-- ============================================================


-- ============================================================
-- BAGIAN 1: BERSIHKAN DATABASE LAMA (jika ada)
-- ============================================================
DROP TABLE IF EXISTS transaksi_distribusi CASCADE;
DROP TABLE IF EXISTS inventaris_stok CASCADE;
DROP TABLE IF EXISTS produk_pangan CASCADE;
DROP TABLE IF EXISTS region CASCADE;


-- ============================================================
-- BAGIAN 2: BUAT TABEL (SKEMA)
-- ============================================================

-- Tabel 1: Region (Wilayah Distribusi)
CREATE TABLE region (
    id_wilayah      VARCHAR(10)  PRIMARY KEY,
    nama_wilayah    VARCHAR(100) NOT NULL,
    provinsi        VARCHAR(100) NOT NULL,
    zona_distribusi VARCHAR(20)  NOT NULL
);

-- Tabel 2: Produk Pangan (Komoditas)
CREATE TABLE produk_pangan (
    id_komoditas   VARCHAR(20)   PRIMARY KEY,
    nama_komoditas VARCHAR(100)  NOT NULL,
    satuan         VARCHAR(20)   NOT NULL,
    harga_satuan   NUMERIC(12,2) NOT NULL
);

-- Tabel 3: Inventaris Stok
CREATE TABLE inventaris_stok (
    id_wilayah   VARCHAR(10) NOT NULL REFERENCES region(id_wilayah),
    id_komoditas VARCHAR(20) NOT NULL REFERENCES produk_pangan(id_komoditas),
    jumlah       INTEGER     NOT NULL,
    updated_at   TIMESTAMP   NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_wilayah, id_komoditas),
    CONSTRAINT stok_non_negatif CHECK (jumlah >= 0)
);

-- Tabel 4: Transaksi Distribusi
CREATE TABLE transaksi_distribusi (
    id_transaksi        VARCHAR(50) PRIMARY KEY,
    id_wilayah_asal     VARCHAR(10) NOT NULL REFERENCES region(id_wilayah),
    id_wilayah_tujuan   VARCHAR(10) NOT NULL REFERENCES region(id_wilayah),
    id_komoditas        VARCHAR(20) NOT NULL REFERENCES produk_pangan(id_komoditas),
    jumlah_distribusi   INTEGER     NOT NULL CHECK (jumlah_distribusi > 0),
    status              VARCHAR(20) NOT NULL DEFAULT 'SELESAI',
    timestamp_transaksi TIMESTAMP   NOT NULL DEFAULT NOW(),
    keterangan          TEXT
);


-- ============================================================
-- BAGIAN 3: ISI DATA DUMMY
-- ============================================================

-- Data Region (10 Wilayah)
INSERT INTO region VALUES
('JB', 'Jawa Barat',          'Jawa Barat',        'BARAT'),
('JT', 'Jawa Tengah',         'Jawa Tengah',       'TENGAH'),
('JK', 'DKI Jakarta',         'DKI Jakarta',       'BARAT'),
('JI', 'Jawa Timur',          'Jawa Timur',        'TENGAH'),
('SL', 'Sumatera Selatan',    'Sumatera Selatan',  'BARAT'),
('SU', 'Sumatera Utara',      'Sumatera Utara',    'BARAT'),
('KL', 'Kalimantan Selatan',  'Kalimantan Selatan','TIMUR'),
('SN', 'Sulawesi Selatan',    'Sulawesi Selatan',  'TIMUR'),
('BL', 'Bali',                'Bali',              'TENGAH'),
('NB', 'Nusa Tenggara Barat', 'NTB',               'TIMUR');


-- Data Produk Pangan (5 Komoditas)
INSERT INTO produk_pangan VALUES
('BERAS',   'Beras Medium',   'KG',    12500.00),
('JAGUNG',  'Jagung Pipilan', 'KG',     5800.00),
('KEDELAI', 'Kedelai Lokal',  'KG',    14000.00),
('GULA',    'Gula Pasir',     'KG',    17000.00),
('MINYAK',  'Minyak Goreng',  'LITER', 18500.00);


-- Data Inventaris Stok (10 wilayah x 5 komoditas = 50 baris)
INSERT INTO inventaris_stok (id_wilayah, id_komoditas, jumlah) VALUES
('JB', 'BERAS',   15000), ('JB', 'JAGUNG',  8000), ('JB', 'KEDELAI', 4500),
('JB', 'GULA',    3200),  ('JB', 'MINYAK',  2800),
('JT', 'BERAS',   18000), ('JT', 'JAGUNG', 12000), ('JT', 'KEDELAI', 6000),
('JT', 'GULA',    4500),  ('JT', 'MINYAK',  3500),
('JK', 'BERAS',    9000), ('JK', 'JAGUNG',  3000), ('JK', 'KEDELAI', 2000),
('JK', 'GULA',    5000),  ('JK', 'MINYAK',  6000),
('JI', 'BERAS',   20000), ('JI', 'JAGUNG', 15000), ('JI', 'KEDELAI', 8000),
('JI', 'GULA',    3800),  ('JI', 'MINYAK',  4200),
('SL', 'BERAS',   12000), ('SL', 'JAGUNG',  7500), ('SL', 'KEDELAI', 3500),
('SL', 'GULA',    2800),  ('SL', 'MINYAK',  2200),
('SU', 'BERAS',   11000), ('SU', 'JAGUNG',  6000), ('SU', 'KEDELAI', 3000),
('SU', 'GULA',    2500),  ('SU', 'MINYAK',  2000),
('KL', 'BERAS',    7500), ('KL', 'JAGUNG',  4000), ('KL', 'KEDELAI', 1800),
('KL', 'GULA',    1500),  ('KL', 'MINYAK',  1800),
('SN', 'BERAS',   13000), ('SN', 'JAGUNG',  9000), ('SN', 'KEDELAI', 4000),
('SN', 'GULA',    2000),  ('SN', 'MINYAK',  1500),
('BL', 'BERAS',    5000), ('BL', 'JAGUNG',  2500), ('BL', 'KEDELAI', 1200),
('BL', 'GULA',    1800),  ('BL', 'MINYAK',  2100),
('NB', 'BERAS',    4500), ('NB', 'JAGUNG',  2000), ('NB', 'KEDELAI',  900),
('NB', 'GULA',    1200),  ('NB', 'MINYAK',  1000);


-- Data Transaksi Distribusi (30 transaksi historis)
INSERT INTO transaksi_distribusi VALUES
('TRX-001','JI','JK','BERAS',  500,'SELESAI','2026-01-05 08:00:00','Distribusi rutin Januari'),
('TRX-002','JT','JK','GULA',   200,'SELESAI','2026-01-06 09:30:00','Tambahan stok Jakarta'),
('TRX-003','JB','SL','JAGUNG', 300,'SELESAI','2026-01-07 10:00:00','Distribusi antar pulau'),
('TRX-004','JI','SN','BERAS',  800,'SELESAI','2026-01-08 11:00:00','Distribusi ke Sulawesi'),
('TRX-005','JT','BL','MINYAK', 150,'SELESAI','2026-01-09 13:00:00','Kebutuhan Bali'),
('TRX-006','JB','JK','BERAS',  400,'SELESAI','2026-01-10 07:30:00','Pasokan harian Jakarta'),
('TRX-007','SU','KL','KEDELAI',200,'SELESAI','2026-01-11 08:45:00','Distribusi ke Kalimantan'),
('TRX-008','JI','NB','BERAS',  600,'SELESAI','2026-01-12 09:00:00','Bantuan pangan NTB'),
('TRX-009','JT','SN','JAGUNG', 400,'SELESAI','2026-01-13 10:30:00','Pakan ternak Sulawesi'),
('TRX-010','JB','SU','GULA',   250,'SELESAI','2026-01-14 11:00:00','Distribusi Sumatera Utara'),
('TRX-011','JI','KL','BERAS',  700,'SELESAI','2026-02-01 08:00:00','Distribusi Februari'),
('TRX-012','JT','NB','KEDELAI',180,'SELESAI','2026-02-03 09:00:00','Pemenuhan kebutuhan NTB'),
('TRX-013','SN','BL','JAGUNG', 120,'SELESAI','2026-02-05 10:00:00','Distribusi antar timur'),
('TRX-014','JB','JT','MINYAK', 300,'SELESAI','2026-02-07 11:30:00','Kebutuhan Jawa Tengah'),
('TRX-015','JI','JB','BERAS',  500,'SELESAI','2026-02-10 08:00:00','Balik distribusi Jawa'),
('TRX-016','SL','KL','BERAS',  350,'SELESAI','2026-02-12 09:30:00','Distribusi Kalimantan'),
('TRX-017','JT','JK','KEDELAI',280,'SELESAI','2026-02-14 10:00:00','Kebutuhan industri Jakarta'),
('TRX-018','JB','BL','GULA',   100,'SELESAI','2026-02-16 11:00:00','Kebutuhan pariwisata Bali'),
('TRX-019','SU','SL','JAGUNG', 500,'SELESAI','2026-02-18 13:00:00','Distribusi intra Sumatera'),
('TRX-020','JI','SN','GULA',   200,'SELESAI','2026-02-20 08:00:00','Pasokan Sulawesi'),
('TRX-021','JT','KL','MINYAK', 200,'SELESAI','2026-03-01 08:00:00','Distribusi Maret'),
('TRX-022','JB','JI','BERAS',  600,'SELESAI','2026-03-03 09:00:00','Penguatan stok Jawa Timur'),
('TRX-023','SN','NB','BERAS',  250,'SELESAI','2026-03-05 10:30:00','Pemenuhan NTB'),
('TRX-024','JK','BL','MINYAK', 180,'SELESAI','2026-03-07 11:00:00','Distribusi dari Jakarta'),
('TRX-025','JI','SU','JAGUNG', 450,'SELESAI','2026-03-10 08:00:00','Pakan ternak Sumatera'),
('TRX-026','JT','SL','KEDELAI',320,'SELESAI','2026-03-12 09:30:00','Industri tahu Sumatera'),
('TRX-027','JB','KL','GULA',   150,'SELESAI','2026-03-15 10:00:00','Kebutuhan Kalimantan'),
('TRX-028','SU','SN','BERAS',  400,'SELESAI','2026-03-18 11:00:00','Distribusi antar timur'),
('TRX-029','JI','BL','KEDELAI',100,'SELESAI','2026-03-20 13:00:00','Kebutuhan Bali'),
('TRX-030','JT','NB','MINYAK', 120,'SELESAI','2026-03-22 08:00:00','Distribusi ke NTB');


-- ============================================================
-- BAGIAN 4: VERIFIKASI DATA
-- ============================================================

SELECT '=== VERIFIKASI JUMLAH DATA ===' AS info;
SELECT 'region'             AS tabel, COUNT(*) AS jumlah_baris FROM region
UNION ALL
SELECT 'produk_pangan',               COUNT(*)                 FROM produk_pangan
UNION ALL
SELECT 'inventaris_stok',             COUNT(*)                 FROM inventaris_stok
UNION ALL
SELECT 'transaksi_distribusi',        COUNT(*)                 FROM transaksi_distribusi;

SELECT '=== TOTAL STOK NASIONAL BASELINE ===' AS info;
SELECT
    p.nama_komoditas,
    SUM(i.jumlah) AS total_stok_nasional,
    p.satuan
FROM inventaris_stok i
JOIN produk_pangan p ON i.id_komoditas = p.id_komoditas
GROUP BY p.nama_komoditas, p.satuan
ORDER BY p.nama_komoditas;

SELECT '=== STOK BERAS PER WILAYAH ===' AS info;
SELECT
    r.nama_wilayah,
    i.jumlah AS stok_beras_kg
FROM inventaris_stok i
JOIN region r ON i.id_wilayah = r.id_wilayah
WHERE i.id_komoditas = 'BERAS'
ORDER BY i.jumlah DESC;

SELECT '✅ Setup selesai! Database siap untuk pengujian ACID.' AS status;
