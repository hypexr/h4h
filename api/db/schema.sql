
CREATE TABLE `users` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) DEFAULT NULL,
  `first_name` VARCHAR(255) DEFAULT NULL,
  `last_name` VARCHAR(255) DEFAULT NULL,
  `hashed_password` VARCHAR(255) DEFAULT NULL,
  `salt` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `comments` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `user_id` MEDIUMINT,
  `message` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `comments_user_id_idx` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


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
  `display_ratio` INTEGER DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `hospitals_rating_criteria_idx` (`rating_criteria`),
  KEY `hospitals_procedure_idx` (`procedure`),
  KEY `hospitals_county_idx` (`county`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `procedures` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hospital_procedures` (
  `hospital_id` MEDIUMINT,
  `procedure_id` MEDIUMINT,
  CONSTRAINT `hp_hospital_id_idx` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`id`),
  CONSTRAINT `hp_procedure_id_idx` FOREIGN KEY (`procedure_id`) REFERENCES `procedures` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rating_criteria` (
  `id` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hospital_rating_criteria` (
  `hospital_id` MEDIUMINT,
  `rating_criteria_id` MEDIUMINT,
  CONSTRAINT `hp_hospital_id_idx` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`id`),
  CONSTRAINT `hp_rating_criteria_id_idx` FOREIGN KEY (`rating_criteria_id`) REFERENCES `rating_criteria` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;