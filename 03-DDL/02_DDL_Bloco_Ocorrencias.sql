
-- 1. LIMPEZA DAS TABELAS DO BLOCO OCORRENCIAS

DROP VIEW IF EXISTS vw_idade_cidadao;

DROP TABLE IF EXISTS ficha_inquerito;
DROP TABLE IF EXISTS bo_cidadao;
DROP TABLE IF EXISTS bo_tipo;
DROP TABLE IF EXISTS bo;
DROP TABLE IF EXISTS tipo_ocorrencia;
DROP TABLE IF EXISTS cidadao;

-- 2. TABELA CIDADAO
-- A idade sera calculada posteriormente por uma VIEW.

CREATE TABLE cidadao (
    cpf CHAR(11) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) NOT NULL,

    CONSTRAINT pk_cidadao
        PRIMARY KEY (cpf),

    CONSTRAINT ck_cidadao_cpf
        CHECK (cpf ~ '^[0-9]{11}$'),

    CONSTRAINT ck_cidadao_email
        CHECK (email LIKE '%_@_%._%'),

    CONSTRAINT ck_cidadao_nasc
        CHECK (data_nascimento >= DATE '1900-01-01')
);

-- 3. TABELA TIPO_OCORRENCIA

CREATE TABLE tipo_ocorrencia (
    codigo_artigo VARCHAR(30) NOT NULL,
    descricao_tecnica VARCHAR(255) NOT NULL,

    CONSTRAINT pk_tipo_ocorrencia
        PRIMARY KEY (codigo_artigo)
);

-- 4. TABELA BO (BOLETIM DE OCORRENCIA)

CREATE TABLE bo (
    numero_protocolo VARCHAR(20) NOT NULL,
    data_hora_fato TIMESTAMP NOT NULL,
    descricao_narrativa TEXT NOT NULL,
    data_registro TIMESTAMP NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    status VARCHAR(30) NOT NULL
        DEFAULT 'Em Investigação',

    id_delegacia INT NOT NULL,
    matricula_delegado VARCHAR(10) NOT NULL,

    CONSTRAINT pk_bo
        PRIMARY KEY (numero_protocolo),

    CONSTRAINT ck_bo_status
        CHECK (status IN (
            'Em Investigação',
            'Concluído',
            'Arquivado'
        )),

    CONSTRAINT ck_bo_datas
        CHECK (data_registro >= data_hora_fato),

    CONSTRAINT fk_bo_delegacia
        FOREIGN KEY (id_delegacia)
        REFERENCES delegacia (id_delegacia)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_bo_delegado
        FOREIGN KEY (matricula_delegado)
        REFERENCES delegado (matricula)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- 5. TABELA BO_CIDADAO
-- Relacionamento N:N entre BO e cidadao.

CREATE TABLE bo_cidadao (
    numero_protocolo VARCHAR(20) NOT NULL,
    cpf CHAR(11) NOT NULL,

    CONSTRAINT pk_bo_cidadao
        PRIMARY KEY (numero_protocolo, cpf),

    CONSTRAINT fk_bocidadao_bo
        FOREIGN KEY (numero_protocolo)
        REFERENCES bo (numero_protocolo)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_bocidadao_cidadao
        FOREIGN KEY (cpf)
        REFERENCES cidadao (cpf)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 6. TABELA BO_TIPO
-- Relacionamento N:N entre BO e tipo_ocorrencia.

CREATE TABLE bo_tipo (
    numero_protocolo VARCHAR(20) NOT NULL,
    codigo_artigo VARCHAR(30) NOT NULL,
    observacao_tipificacao VARCHAR(255),

    CONSTRAINT pk_bo_tipo
        PRIMARY KEY (numero_protocolo, codigo_artigo),

    CONSTRAINT fk_botipo_bo
        FOREIGN KEY (numero_protocolo)
        REFERENCES bo (numero_protocolo)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_botipo_tipo
        FOREIGN KEY (codigo_artigo)
        REFERENCES tipo_ocorrencia (codigo_artigo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 7. TABELA FICHA_INQUERITO
-- Relacionamento 1:1 com BO.

CREATE TABLE ficha_inquerito (
    numero_inquerito VARCHAR(25) NOT NULL,
    data_instauracao DATE NOT NULL,

    status_investigacao VARCHAR(20) NOT NULL
        DEFAULT 'Ativo',

    numero_protocolo_bo VARCHAR(20) NOT NULL,

    CONSTRAINT pk_ficha_inquerito
        PRIMARY KEY (numero_inquerito),

    CONSTRAINT uq_ficha_bo
        UNIQUE (numero_protocolo_bo),

    CONSTRAINT ck_ficha_status
        CHECK (status_investigacao IN (
            'Ativo',
            'Relatado',
            'Arquivado',
            'Suspenso'
        )),

    CONSTRAINT ck_ficha_data
        CHECK (data_instauracao >= DATE '2000-01-01'),

    CONSTRAINT fk_ficha_bo
        FOREIGN KEY (numero_protocolo_bo)
        REFERENCES bo (numero_protocolo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 8. CONFERENCIA DAS TABELAS

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
