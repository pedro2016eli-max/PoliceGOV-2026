-- =====================================================================
-- PoliceGOV - Sistema de Boletim de Ocorrencias Estadual
-- Arquivo : 01_DDL_Estrutura_Policial.sql
-- Autor   : Alan (Bloco Estrutura Policial)
-- SGBD    : MySQL 8.0.16 ou superior (necessario para CHECK funcionar)
-- Conteudo: criacao do banco e das tabelas delegacia, delegacia_telefone,
--           policial, delegado e investigador_escrivao.
-- Obs.    : as tabelas do bloco Ocorrencias sao apagadas no inicio
--           (DROP IF EXISTS) para o script poder ser reexecutado do zero.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS policegov
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE policegov;

-- ---------------------------------------------------------------------
-- 1. LIMPEZA (ordem inversa de dependencia)
-- ---------------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW  IF EXISTS vw_idade_cidadao;
DROP TABLE IF EXISTS ficha_inquerito;
DROP TABLE IF EXISTS bo_cidadao;
DROP TABLE IF EXISTS bo_tipo;
DROP TABLE IF EXISTS bo;
DROP TABLE IF EXISTS tipo_ocorrencia;
DROP TABLE IF EXISTS cidadao;
DROP TABLE IF EXISTS investigador_escrivao;
DROP TABLE IF EXISTS delegado;
DROP TABLE IF EXISTS policial;
DROP TABLE IF EXISTS delegacia_telefone;
DROP TABLE IF EXISTS delegacia;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
-- 2. DELEGACIA (endereco composto fica em colunas da propria tabela)
-- ---------------------------------------------------------------------
CREATE TABLE delegacia (
    id_delegacia  INT          NOT NULL AUTO_INCREMENT,
    nome          VARCHAR(100) NOT NULL,
    municipio     VARCHAR(60)  NOT NULL,
    logradouro    VARCHAR(100) NOT NULL,
    numero        INT          NOT NULL,
    bairro        VARCHAR(60)  NOT NULL,
    cep           CHAR(8)      NOT NULL,
    cidade        VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_delegacia        PRIMARY KEY (id_delegacia),
    CONSTRAINT uq_delegacia_nome   UNIQUE (nome),
    CONSTRAINT ck_delegacia_numero CHECK (numero > 0),
    CONSTRAINT ck_delegacia_cep    CHECK (cep REGEXP '^[0-9]{8}$')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. DELEGACIA_TELEFONE (atributo multivalorado -> tabela propria)
-- ---------------------------------------------------------------------
CREATE TABLE delegacia_telefone (
    id_delegacia  INT         NOT NULL,
    telefone      VARCHAR(11) NOT NULL,
    CONSTRAINT pk_delegacia_telefone PRIMARY KEY (id_delegacia, telefone),
    CONSTRAINT fk_telefone_delegacia FOREIGN KEY (id_delegacia)
        REFERENCES delegacia (id_delegacia)
        ON DELETE CASCADE ON UPDATE RESTRICT,
    CONSTRAINT ck_telefone_formato CHECK (telefone REGEXP '^[0-9]{10,11}$')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. POLICIAL (superclasse da especializacao)
--    UNIQUE (matricula, cargo) permite a FK composta usada pelas
--    subclasses (garante a coerencia entre cargo e subtipo).
-- ---------------------------------------------------------------------
CREATE TABLE policial (
    matricula     VARCHAR(10)  NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL,
    cargo         VARCHAR(30)  NOT NULL,
    id_delegacia  INT          NOT NULL,
    CONSTRAINT pk_policial       PRIMARY KEY (matricula),
    CONSTRAINT uq_policial_email UNIQUE (email),
    CONSTRAINT uq_policial_matricula_cargo UNIQUE (matricula, cargo),
    CONSTRAINT fk_policial_delegacia FOREIGN KEY (id_delegacia)
        REFERENCES delegacia (id_delegacia)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_policial_cargo CHECK
        (cargo IN ('Delegado de Polícia', 'Investigador', 'Escrivão')),
    CONSTRAINT ck_policial_email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT ck_policial_matricula CHECK (matricula REGEXP '^[0-9]{6,10}$')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. DELEGADO (subclasse) - mapeamento por tabela de subclasse
--    PK = FK para policial. A FK composta (matricula, cargo) com o CHECK
--    garante que so entra aqui quem tem cargo 'Delegado de Polícia'.
-- ---------------------------------------------------------------------
CREATE TABLE delegado (
    matricula        VARCHAR(10) NOT NULL,
    cargo            VARCHAR(30) NOT NULL DEFAULT 'Delegado de Polícia',
    numero_portaria  VARCHAR(20) NOT NULL,
    CONSTRAINT pk_delegado PRIMARY KEY (matricula),
    CONSTRAINT uq_delegado_portaria UNIQUE (numero_portaria),
    CONSTRAINT fk_delegado_policial FOREIGN KEY (matricula, cargo)
        REFERENCES policial (matricula, cargo)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_delegado_cargo CHECK (cargo = 'Delegado de Polícia')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. INVESTIGADOR_ESCRIVAO (subclasse)
-- ---------------------------------------------------------------------
CREATE TABLE investigador_escrivao (
    matricula      VARCHAR(10) NOT NULL,
    cargo          VARCHAR(30) NOT NULL,
    area_atuacao   VARCHAR(80) NOT NULL,
    CONSTRAINT pk_investigador_escrivao PRIMARY KEY (matricula),
    CONSTRAINT fk_inv_esc_policial FOREIGN KEY (matricula, cargo)
        REFERENCES policial (matricula, cargo)
        ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT ck_inv_esc_cargo CHECK (cargo IN ('Investigador', 'Escrivão'))
) ENGINE=InnoDB;

SHOW TABLES;
