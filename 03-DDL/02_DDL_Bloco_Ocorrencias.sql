-- =====================================================================
-- PoliceGOV - Sistema de Boletim de Ocorrencias Estadual
-- Arquivo : 02_DDL_Bloco_Ocorrencias.sql
-- SGBD    : MySQL 8.0.16 ou superior
-- Conteudo: tabelas cidadao, tipo_ocorrencia, bo, bo_cidadao, bo_tipo
--           e ficha_inquerito.
-- Depende : 01_DDL_Estrutura_Policial.sql (delegacia e delegado).
-- =====================================================================

USE policegov;

DROP VIEW  IF EXISTS vw_idade_cidadao;
DROP TABLE IF EXISTS ficha_inquerito;
DROP TABLE IF EXISTS bo_cidadao;
DROP TABLE IF EXISTS bo_tipo;
DROP TABLE IF EXISTS bo;
DROP TABLE IF EXISTS tipo_ocorrencia;
DROP TABLE IF EXISTS cidadao;

-- ---------------------------------------------------------------------
-- 1. CIDADAO
-- A idade e um atributo derivado de data_nascimento e nao e armazenada
-- (ela e calculada pela view vw_idade_cidadao).
-- ---------------------------------------------------------------------
CREATE TABLE cidadao (
    cpf             CHAR(11)     NOT NULL,
    nome            VARCHAR(150) NOT NULL,
    data_nascimento DATE         NOT NULL,
    email           VARCHAR(100) NOT NULL,
    CONSTRAINT pk_cidadao PRIMARY KEY (cpf),
    CONSTRAINT ck_cidadao_cpf   CHECK (cpf REGEXP '^[0-9]{11}$'),
    CONSTRAINT ck_cidadao_email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT ck_cidadao_nasc  CHECK (data_nascimento >= '1900-01-01')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. TIPO_OCORRENCIA
-- ---------------------------------------------------------------------
CREATE TABLE tipo_ocorrencia (
    codigo_artigo      VARCHAR(30)  NOT NULL,
    descricao_tecnica  VARCHAR(255) NOT NULL,
    CONSTRAINT pk_tipo_ocorrencia PRIMARY KEY (codigo_artigo)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. BO (Boletim de Ocorrencia)
-- registrado em uma delegacia (N:1) e assinado por um delegado (N:1)
-- ---------------------------------------------------------------------
CREATE TABLE bo (
    numero_protocolo    VARCHAR(20) NOT NULL,
    data_hora_fato      DATETIME    NOT NULL,
    descricao_narrativa TEXT        NOT NULL,
    data_registro       DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status              ENUM('Em Investigação', 'Concluído', 'Arquivado')
                        NOT NULL DEFAULT 'Em Investigação',
    id_delegacia        INT         NOT NULL,
    matricula_delegado  VARCHAR(10) NOT NULL,
    CONSTRAINT pk_bo PRIMARY KEY (numero_protocolo),
    CONSTRAINT ck_bo_datas CHECK (data_registro >= data_hora_fato),
    CONSTRAINT fk_bo_delegacia FOREIGN KEY (id_delegacia)
        REFERENCES delegacia (id_delegacia)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_bo_delegado FOREIGN KEY (matricula_delegado)
        REFERENCES delegado (matricula)
        ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. BO_CIDADAO (relacionamento N:N "envolve" entre BO e Cidadao)
-- ---------------------------------------------------------------------
CREATE TABLE bo_cidadao (
    numero_protocolo VARCHAR(20) NOT NULL,
    cpf              CHAR(11)    NOT NULL,
    CONSTRAINT pk_bo_cidadao PRIMARY KEY (numero_protocolo, cpf),
    CONSTRAINT fk_bocidadao_bo FOREIGN KEY (numero_protocolo)
        REFERENCES bo (numero_protocolo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_bocidadao_cidadao FOREIGN KEY (cpf)
        REFERENCES cidadao (cpf)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. BO_TIPO (relacionamento N:N "classifica" entre BO e Tipo_Ocorrencia)
-- ---------------------------------------------------------------------
CREATE TABLE bo_tipo (
    numero_protocolo        VARCHAR(20)  NOT NULL,
    codigo_artigo           VARCHAR(30)  NOT NULL,
    observacao_tipificacao  VARCHAR(255) NULL,
    CONSTRAINT pk_bo_tipo PRIMARY KEY (numero_protocolo, codigo_artigo),
    CONSTRAINT fk_botipo_bo FOREIGN KEY (numero_protocolo)
        REFERENCES bo (numero_protocolo)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_botipo_tipo FOREIGN KEY (codigo_artigo)
        REFERENCES tipo_ocorrencia (codigo_artigo)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. FICHA_INQUERITO (relacionamento 1:1 com BO)
-- O UNIQUE na FK garante que cada BO gere no maximo uma ficha.
-- ---------------------------------------------------------------------
CREATE TABLE ficha_inquerito (
    numero_inquerito     VARCHAR(25) NOT NULL,
    data_instauracao     DATE        NOT NULL,
    status_investigacao  ENUM('Ativo', 'Relatado', 'Arquivado', 'Suspenso')
                         NOT NULL DEFAULT 'Ativo',
    numero_protocolo_bo  VARCHAR(20) NOT NULL,
    CONSTRAINT pk_ficha_inquerito PRIMARY KEY (numero_inquerito),
    CONSTRAINT uq_ficha_bo UNIQUE (numero_protocolo_bo),
    CONSTRAINT ck_ficha_data CHECK (data_instauracao >= '2000-01-01'),
    CONSTRAINT fk_ficha_bo FOREIGN KEY (numero_protocolo_bo)
        REFERENCES bo (numero_protocolo)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

SHOW TABLES;
