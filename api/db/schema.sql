
DROP TABLE `hospitals`;

CREATE TABLE `hospitals` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT NULL,
  `rating_criteria` VARCHAR(255) DEFAULT NULL,
  `procedure` VARCHAR(255) DEFAULT NULL,
  `procedures` text DEFAULT NULL,
  `county` VARCHAR(255) DEFAULT NULL,
  `occurrences` INTEGER DEFAULT NULL,
  `out_of` INTEGER DEFAULT NULL,
  `risk_ratio` INTEGER DEFAULT NULL,
  `min_occurrences` INTEGER DEFAULT NULL,
  `max_occurrences` INTEGER DEFAULT NULL,
  `display_percentage` FLOAT(5,2) DEFAULT NULL,
  `occurrence_data_available` INTEGER DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `hospitals_rating_criteria_idx` (`rating_criteria`),
  KEY `hospitals_procedure_idx` (`procedure`),
  KEY `hospitals_county_idx` (`county`),
  KEY `hospitals_display_percentage_idx` (`display_percentage`),
  KEY `hospitals_oda_idx` (`occurrence_data_available`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
