-- Database: db_pengeringan

CREATE DATABASE IF NOT EXISTS `db_pengeringan` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `db_pengeringan`;

-- Table for alternatif AHP (from your alternantif_ahp.sql)
CREATE TABLE IF NOT EXISTS `alternantif_ahp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nama` (`nama`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for users (login system)
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for proses pengeringan (main data)
CREATE TABLE IF NOT EXISTS `proses_pengeringan` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `bahan_bakar` varchar(100) NOT NULL,
  `suhu` decimal(10,2) NOT NULL,
  `waktu` decimal(10,2) NOT NULL COMMENT 'dalam jam',
  `biaya` decimal(15,2) NOT NULL,
  `konsumsi` decimal(10,2) NOT NULL COMMENT 'dalam kg',
  `output` decimal(10,2) NOT NULL COMMENT 'dalam kg jagung kering',
  `tanggal` date NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `tanggal` (`tanggal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for AHP criteria
CREATE TABLE IF NOT EXISTS `ahp_kriteria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `nama` (`nama`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for AHP pairwise comparisons (criteria)
CREATE TABLE IF NOT EXISTS `ahp_perbandingan_kriteria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kriteria1_id` int(11) NOT NULL,
  `kriteria2_id` int(11) NOT NULL,
  `nilai` decimal(10,4) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_comparison` (`kriteria1_id`,`kriteria2_id`),
  KEY `kriteria2_id` (`kriteria2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for AHP pairwise comparisons (alternatives)
CREATE TABLE IF NOT EXISTS `ahp_perbandingan_alternatif` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kriteria_id` int(11) NOT NULL,
  `alternatif1_id` int(11) NOT NULL,
  `alternatif2_id` int(11) NOT NULL,
  `nilai` decimal(10,4) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_comparison` (`kriteria_id`,`alternatif1_id`,`alternatif2_id`),
  KEY `alternatif1_id` (`alternatif1_id`),
  KEY `alternatif2_id` (`alternatif2_id`),
  KEY `kriteria_id` (`kriteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for AHP results
CREATE TABLE IF NOT EXISTS `ahp_hasil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `tanggal` datetime NOT NULL DEFAULT current_timestamp(),
  `cr_kriteria` decimal(10,4) NOT NULL COMMENT 'Consistency Ratio',
  `alternatif_terbaik_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `alternatif_terbaik_id` (`alternatif_terbaik_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for AHP result details (criteria weights)
CREATE TABLE IF NOT EXISTS `ahp_hasil_detail_kriteria` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hasil_id` int(11) NOT NULL,
  `kriteria_id` int(11) NOT NULL,
  `bobot` decimal(10,4) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_detail` (`hasil_id`,`kriteria_id`),
  KEY `kriteria_id` (`kriteria_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for AHP result details (alternative scores)
CREATE TABLE IF NOT EXISTS `ahp_hasil_detail_alternatif` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hasil_id` int(11) NOT NULL,
  `alternatif_id` int(11) NOT NULL,
  `skor` decimal(10,4) NOT NULL,
  `ranking` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_detail` (`hasil_id`,`alternatif_id`),
  KEY `alternatif_id` (`alternatif_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key constraints
ALTER TABLE `proses_pengeringan`
  ADD CONSTRAINT `proses_pengeringan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `ahp_perbandingan_kriteria`
  ADD CONSTRAINT `ahp_perbandingan_kriteria_ibfk_1` FOREIGN KEY (`kriteria1_id`) REFERENCES `ahp_kriteria` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ahp_perbandingan_kriteria_ibfk_2` FOREIGN KEY (`kriteria2_id`) REFERENCES `ahp_kriteria` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ahp_perbandingan_alternatif`
  ADD CONSTRAINT `ahp_perbandingan_alternatif_ibfk_1` FOREIGN KEY (`kriteria_id`) REFERENCES `ahp_kriteria` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ahp_perbandingan_alternatif_ibfk_2` FOREIGN KEY (`alternatif1_id`) REFERENCES `alternantif_ahp` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ahp_perbandingan_alternatif_ibfk_3` FOREIGN KEY (`alternatif2_id`) REFERENCES `alternantif_ahp` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ahp_hasil`
  ADD CONSTRAINT `ahp_hasil_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `ahp_hasil_ibfk_2` FOREIGN KEY (`alternatif_terbaik_id`) REFERENCES `alternantif_ahp` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `ahp_hasil_detail_kriteria`
  ADD CONSTRAINT `ahp_hasil_detail_kriteria_ibfk_1` FOREIGN KEY (`hasil_id`) REFERENCES `ahp_hasil` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ahp_hasil_detail_kriteria_ibfk_2` FOREIGN KEY (`kriteria_id`) REFERENCES `ahp_kriteria` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `ahp_hasil_detail_alternatif`
  ADD CONSTRAINT `ahp_hasil_detail_alternatif_ibfk_1` FOREIGN KEY (`hasil_id`) REFERENCES `ahp_hasil` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `ahp_hasil_detail_alternatif_ibfk_2` FOREIGN KEY (`alternatif_id`) REFERENCES `alternantif_ahp` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- Insert initial data
INSERT INTO `ahp_kriteria` (`nama`) VALUES 
('Efisiensi Energi'),
('Biaya Pengeringan'),
('Suhu Pembakaran'),
('Ketersediaan Bahan');

INSERT INTO `alternantif_ahp` (`nama`) VALUES 
('Cangkang Sawit'),
('Woodchips'),
('Bonggol Jagung');

-- Create a default user (password: admin123)
INSERT INTO `users` (`username`, `password`, `nama_lengkap`) VALUES 
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator');