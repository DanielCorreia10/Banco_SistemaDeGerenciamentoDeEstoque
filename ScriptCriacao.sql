-- -----------------------------------------------------
-- Schema db_my_epi
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `db_my_epi` DEFAULT CHARACTER SET utf8 ;
USE `db_my_epi` ;

-- -----------------------------------------------------
-- Table `db_my_epi`.`CARGO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`CARGO` (
  `nome_cargo` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`nome_cargo`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db_my_epi`.`FUNCIONARIO`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`FUNCIONARIO` (
  `idFUNCIONARIO` INT NOT NULL AUTO_INCREMENT,
  `nome_funcionario` VARCHAR(45) NOT NULL,
  `sobrenome_funcionario` VARCHAR(45) NULL,
  `setor` VARCHAR(45) NULL,
  `cpf` VARCHAR(14) NULL,
  `logradouro` VARCHAR(45) NULL,
  `numero` VARCHAR(10) NULL,
  `bairro` VARCHAR(45) NULL,
  `cidade` VARCHAR(45) NULL,
  `estado` VARCHAR(45) NULL,
  `ddd` VARCHAR(3) NOT NULL,
  `telefone` VARCHAR(15) NOT NULL,
  `dt_nascimento` DATE NOT NULL,
  `dt_admissao` DATE NOT NULL,
  `tipo_sanguineo` VARCHAR(3) NOT NULL,
  `CARGO_nome_cargo` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`idFUNCIONARIO`),
  INDEX `fk_FUNCIONARIO_CARGO1_idx` (`CARGO_nome_cargo` ASC) ,
  CONSTRAINT `fk_FUNCIONARIO_CARGO1`
    FOREIGN KEY (`CARGO_nome_cargo`)
    REFERENCES `db_my_epi`.`CARGO` (`nome_cargo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `db_my_epi`.`MARCA`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`MARCA` (
  `idMARCA` INT NOT NULL AUTO_INCREMENT,
  `nome_marca` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idMARCA`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db_my_epi`.`EPI`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`EPI` (
  `idEPI` INT NOT NULL AUTO_INCREMENT,
  `MARCA_idMARCA` INT NOT NULL,
  `nome_epi` VARCHAR(45) NOT NULL,
  `tipo_epi` VARCHAR(30) NOT NULL,
  `quantidade_estoque` INT NOT NULL,
  `validade_epi` DATE NOT NULL,
  `descricao_epi` VARCHAR(200) NULL,
  PRIMARY KEY (`idEPI`, `MARCA_idMARCA`),
  INDEX `fk_EPI_MARCA1_idx` (`MARCA_idMARCA` ASC),
  CONSTRAINT `fk_EPI_MARCA1`
    FOREIGN KEY (`MARCA_idMARCA`)
    REFERENCES `db_my_epi`.`MARCA` (`idMARCA`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db_my_epi`.`ATIVIDADE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`ATIVIDADE` (
  `idATIVIDADE` INT NOT NULL AUTO_INCREMENT,
  `tipo_atividade` VARCHAR(45) NOT NULL,
  `descricao_atividade` VARCHAR(45) NULL,
  PRIMARY KEY (`idATIVIDADE`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db_my_epi`.`FUNCIONARIO_EPI`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`FUNCIONARIO_EPI` (
  `id_entrega` INT NOT NULL AUTO_INCREMENT,
  `data_e_hora` DATETIME NOT NULL,
  `situacao_entrega` VARCHAR(20) NOT NULL,
  `quantidade_entregue` INT NOT NULL,
  `descricao_entrega` VARCHAR(45) NULL,
  `FUNCIONARIO_idFUNCIONARIO` INT NOT NULL,
  `EPI_idEPI` INT NOT NULL,
  PRIMARY KEY (`id_entrega`, `FUNCIONARIO_idFUNCIONARIO`, `EPI_idEPI`),
  INDEX `fk_FUNCIONARIO_has_EPI_EPI1_idx` (`EPI_idEPI` ASC) ,
  INDEX `fk_FUNCIONARIO_has_EPI_FUNCIONARIO_idx` (`FUNCIONARIO_idFUNCIONARIO` ASC) ,
  CONSTRAINT `fk_FUNCIONARIO_has_EPI_FUNCIONARIO`
    FOREIGN KEY (`FUNCIONARIO_idFUNCIONARIO`)
    REFERENCES `db_my_epi`.`FUNCIONARIO` (`idFUNCIONARIO`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_FUNCIONARIO_has_EPI_EPI1`
    FOREIGN KEY (`EPI_idEPI`)
    REFERENCES `db_my_epi`.`EPI` (`idEPI`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db_my_epi`.`CARGO_ATIVIDADE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`CARGO_ATIVIDADE` (
  `CARGO_nome_cargo` VARCHAR(30) NOT NULL,
  `ATIVIDADE_idATIVIDADE` INT NOT NULL,
  PRIMARY KEY (`CARGO_nome_cargo`, `ATIVIDADE_idATIVIDADE`),
  INDEX `fk_CARGO_has_ATIVIDADE_ATIVIDADE1_idx` (`ATIVIDADE_idATIVIDADE` ASC) ,
  INDEX `fk_CARGO_has_ATIVIDADE_CARGO1_idx` (`CARGO_nome_cargo` ASC) ,
  CONSTRAINT `fk_CARGO_has_ATIVIDADE_CARGO1`
    FOREIGN KEY (`CARGO_nome_cargo`)
    REFERENCES `db_my_epi`.`CARGO` (`nome_cargo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_CARGO_has_ATIVIDADE_ATIVIDADE1`
    FOREIGN KEY (`ATIVIDADE_idATIVIDADE`)
    REFERENCES `db_my_epi`.`ATIVIDADE` (`idATIVIDADE`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `db_my_epi`.`EPI_ATIVIDADE`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `db_my_epi`.`EPI_ATIVIDADE` (
  `EPI_idEPI` INT NOT NULL,
  `ATIVIDADE_idATIVIDADE` INT NOT NULL,
  PRIMARY KEY (`EPI_idEPI`, `ATIVIDADE_idATIVIDADE`),
  INDEX `fk_EPI_has_ATIVIDADE_ATIVIDADE1_idx` (`ATIVIDADE_idATIVIDADE` ASC) ,
  INDEX `fk_EPI_has_ATIVIDADE_EPI1_idx` (`EPI_idEPI` ASC) ,
  CONSTRAINT `fk_EPI_has_ATIVIDADE_EPI1`
    FOREIGN KEY (`EPI_idEPI`)
    REFERENCES `db_my_epi`.`EPI` (`idEPI`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_EPI_has_ATIVIDADE_ATIVIDADE1`
    FOREIGN KEY (`ATIVIDADE_idATIVIDADE`)
    REFERENCES `db_my_epi`.`ATIVIDADE` (`idATIVIDADE`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;