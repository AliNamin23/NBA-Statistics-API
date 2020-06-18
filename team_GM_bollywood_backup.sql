-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Movies`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Movies` (
	`MovieIDNumber` INT NOT NULL,
	`Genre` VARCHAR(45) NOT NULL,
	`Movie_Title` VARCHAR(45) NOT NULL,
	`Release_Date_Year` VARCHAR(45) NOT NULL,
	`hit/flop` INT NOT NULL,
	PRIMARY KEY (`MovieIDNumber`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Actor Details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Actor Details` (
	`ActorIDNumber` INT NOT NULL,
	`Actor Name` VARCHAR(45) NOT NULL,
	`Actor Movie Count` INT NOT NULL,
	`Actor Rating` INT NOT NULL,
	PRIMARY KEY (`ActorIDNumber`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Director Details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Director Details` (
	`DirectorIDNumber` INT NOT NULL,
	`Director Name` VARCHAR(45) NOT NULL,
	`Director Movie Count` INT NOT NULL,
	`Director Rating` INT NOT NULL,
	PRIMARY KEY (`DirectorIDNumber`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Production`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Production` (
	`ProductionCompanyID` INT NOT NULL,
	`Production Company Address` VARCHAR(200) NOT NULL,
	`Production Company Name` VARCHAR(45) NOT NULL,
	`Production Company Phone Number` VARCHAR(45) NOT NULL,
	`MovieIDNumber` INT NULL,
	PRIMARY KEY (`ProductionCompanyID`),
	INDEX `fk_prd_movie_id_idx` (`MovieIDNumber` ASC),
	CONSTRAINT `fk_prd_movie_id`
		FOREIGN KEY (`MovieIDNumber`)
		REFERENCES `mydb`.`Movies` (`MovieIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Theaters`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Theaters` (
	`TheaterID` INT NOT NULL,
	`Theater Name` VARCHAR(45) NOT NULL,
	`Theater Address` VARCHAR(200) NOT NULL,
	`TheaterPhoneNumber` VARCHAR(45) NOT NULL,
	`MovieIDNumber` INT NULL,
	PRIMARY KEY (`TheaterID`),
	INDEX `fk_thr_movie_id_idx` (`MovieIDNumber` ASC),
	CONSTRAINT `fk_thr_movie_id`
		FOREIGN KEY (`MovieIDNumber`)
		REFERENCES `mydb`.`Movies` (`MovieIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Box Office Earings`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Box Office Earings` (
	`BoxOfficeID` INT NOT NULL,
	`BoxOffice_Earing_In_Theaters` INT NOT NULL,
	`BoxOffice_Days_In_Theaters` INT NOT NULL,
	`BoxOffice_Earning_Out_Of_Theater` INT NOT NULL,
	`MovieIDNumber` INT NULL,
	PRIMARY KEY (`BoxOfficeID`),
	INDEX `fk_bxoffice_movie_id_idx` (`MovieIDNumber` ASC),
	CONSTRAINT `fk_bxoffice_movie_id`
		FOREIGN KEY (`MovieIDNumber`)
		REFERENCES `mydb`.`Movies` (`MovieIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Movies_Actor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Movies_Actor` (
	`ActorIDNumber` INT NOT NULL,
	`MovieIDNumber` INT NOT NULL,
	PRIMARY KEY (`ActorIDNumber`, `MovieIDNumber`),
	INDEX `fk_movieid_idx` (`MovieIDNumber` ASC),
	CONSTRAINT `fk_mv_actor_id`
		FOREIGN KEY (`ActorIDNumber`)
		REFERENCES `mydb`.`Actor Details` (`ActorIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT `fk_act_movie_id`
		FOREIGN KEY (`MovieIDNumber`)
		REFERENCES `mydb`.`Movies` (`MovieIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Movie_Director`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Movie_Director` (
	`MovieIDNumber` INT NOT NULL,
	`DirectorIDNumber` INT NOT NULL,
	PRIMARY KEY (`MovieIDNumber`, `DirectorIDNumber`),
	INDEX `fk_directorid_idx` (`DirectorIDNumber` ASC),
	CONSTRAINT `fk_dir_movie_id`
		FOREIGN KEY (`MovieIDNumber`)
		REFERENCES `mydb`.`Movies` (`MovieIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT `fk_movie_director_id`
		FOREIGN KEY (`DirectorIDNumber`)
		REFERENCES `mydb`.`Director Details` (`DirectorIDNumber`)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- View Query_actorInMovies
-- -----------------------------------------------------
DROP VIEW IF EXISTS query_actorinmovies;  
CREATE VIEW Query_actorInMovies
AS SELECT movies.Movie_Title, `actor details`.`Actor Name`
FROM movies
       JOIN movies_actor ON movies.MovieIDNumber = movies_actor.MovieIDNumber
       JOIN `actor details` ON `actor details`.ActorIDNumber = movies_actor.ActorIDNumber
WHERE `actor details`.`Actor Name` = 'Govinda';

-- -----------------------------------------------------
-- View Query_actorMovieCount
-- -----------------------------------------------------
DROP VIEW IF EXISTS query_actormoviecount;  
CREATE VIEW Query_actorMovieCount
AS SELECT `Actor Name`, MAX(`Actor Movie Count`)
FROM `actor details`;

-- -----------------------------------------------------
-- View Query_directorAndProduction
-- -----------------------------------------------------
DROP VIEW IF EXISTS query_directorandproduction;  
CREATE VIEW Query_directorAndProduction
AS SELECT `director details`.`Director Name`, production.`Production Company Name`
FROM `director details`
       JOIN movie_director ON `director details`.DirectorIDNumber = movie_director.DirectorIDNumber
       JOIN production ON production.MovieIDNumber = movie_director.MovieIDNumber
GROUP BY `director details`.`Director Name`;

-- -----------------------------------------------------
-- View Query_topProduction_companies
-- -----------------------------------------------------
DROP VIEW IF EXISTS query_topproduction_companies;  
CREATE VIEW Query_topProduction_Companies
AS SELECT `Production Company Name`, movies.Movie_Title
FROM production 
		JOIN movies ON movies.MovieIDNumber = production.MovieIDNumber
 WHERE production.MovieIDNumber IN (SELECT movies.MovieIDNumber 
									FROM movies
									WHERE `hit/flop` > 3);

-- -----------------------------------------------------
-- View Query_totalEarnings
-- -----------------------------------------------------
DROP VIEW IF EXISTS query_totalearnings; 
CREATE VIEW Query_totalEarnings
AS SELECT movies.Release_Date_Year, SUM(`box office earings`.BoxOffice_Earing_In_Theaters) AS 'All Movie Earnings'
FROM `box office earings`
       LEFT JOIN movies ON movies.MovieIDNumber = `box office earings`.MovieIDNumber
WHERE movies.Release_Date_Year = 2001;