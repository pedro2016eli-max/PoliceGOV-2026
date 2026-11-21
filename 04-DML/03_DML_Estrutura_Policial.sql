
-- =====================================================================
-- PoliceGOV - Sistema de Boletim de Ocorrencias Estadual
-- Arquivo : 03_DML_Estrutura_Policial.sql
-- Autor   : Alan (Bloco Estrutura Policial)
-- SGBD    : PostgreSQL
-- Conteudo: insercao de delegacias, telefones, policiais,
--           delegados, investigadores e escrivaes.
-- Executar apos os arquivos 01 e 02.
-- =====================================================================

-- IMPORTANTE:
-- Executar conectado ao banco policegov.

-- 1. DELEGACIAS
-- IDs fixos 1, 2 e 3 utilizados nos boletins de ocorrencia.

INSERT INTO delegacia
    (id_delegacia, nome, municipio, logradouro,
     numero, bairro, cep, cidade)
VALUES
    (1, '1ª Delegacia Regional de Juazeiro do Norte',
        'Juazeiro do Norte', 'Rua São Pedro',
        450, 'Centro', '63010000', 'Juazeiro do Norte'),

    (2, '2ª Delegacia Regional de Fortaleza',
        'Fortaleza', 'Avenida Presidente Castelo Branco',
        1200, 'Jacarecanga', '60010000', 'Fortaleza'),

    (3, 'Delegacia Regional de Sobral',
        'Sobral', 'Rua Coronel Rangel',
        85, 'Centro', '62010000', 'Sobral');

-- 2. AJUSTE DA SEQUENCIA AUTOMATICA
-- Necessario porque os IDs foram inseridos manualmente.

SELECT setval(
    pg_get_serial_sequence('delegacia', 'id_delegacia'),
    (SELECT MAX(id_delegacia) FROM delegacia)
);

-- 3. TELEFONES DE PLANTAO

INSERT INTO delegacia_telefone
    (id_delegacia, telefone)
VALUES
    (1, '8835719001'),
    (1, '88999990001'),
    (2, '8532570002'),
    (3, '8836770003'),
    (3, '88999990003');

-- 4. POLICIAIS
-- Primeiro a superclasse.

INSERT INTO policial
    (matricula, nome, email, cargo, id_delegacia)
VALUES
    ('100001', 'Carlos Eduardo Menezes',
     'carlos.menezes@policia.gov.br',
     'Delegado de Polícia', 1),

    ('100002', 'Mariana Alves Teixeira',
     'mariana.teixeira@policia.gov.br',
     'Delegado de Polícia', 2),

    ('200001', 'Roberto Lima Cavalcante',
     'roberto.cavalcante@policia.gov.br',
     'Investigador', 1),

    ('200002', 'Fernanda Souza Pinheiro',
     'fernanda.pinheiro@policia.gov.br',
     'Escrivão', 3);

-- 5. DELEGADOS
-- Especializacao da tabela policial.

INSERT INTO delegado
    (matricula, cargo, numero_portaria)
VALUES
    ('100001', 'Delegado de Polícia',
     'PORT-SSPDS-2021/0147'),

    ('100002', 'Delegado de Polícia',
     'PORT-SSPDS-2022/0312');

-- 6. INVESTIGADORES E ESCRIVAES

INSERT INTO investigador_escrivao
    (matricula, cargo, area_atuacao)
VALUES
    ('200001', 'Investigador',
     'Crimes Patrimoniais'),

    ('200002', 'Escrivão',
     'Cartório de Inquéritos');

-- 7. CONFERENCIA DAS DELEGACIAS E TELEFONES

SELECT
    d.id_delegacia,
    d.nome,
    d.municipio,
    t.telefone
FROM delegacia d
JOIN delegacia_telefone t
    ON t.id_delegacia = d.id_delegacia
ORDER BY
    d.id_delegacia,
    t.telefone;

-- 8. CONFERENCIA DOS POLICIAIS

SELECT
    p.matricula,
    p.nome,
    p.cargo,
    d.numero_portaria,
    ie.area_atuacao
FROM policial p
LEFT JOIN delegado d
    ON d.matricula = p.matricula
LEFT JOIN investigador_escrivao ie
    ON ie.matricula = p.matricula
ORDER BY p.matricula;

-- 9. CONFERENCIA DA QUANTIDADE DE REGISTROS

SELECT 'Delegacias' AS tabela, COUNT(*) AS quantidade
FROM delegacia

UNION ALL

SELECT 'Telefones', COUNT(*)
FROM delegacia_telefone

UNION ALL

SELECT 'Policiais', COUNT(*)
FROM policial

UNION ALL

SELECT 'Delegados', COUNT(*)
FROM delegado

UNION ALL

SELECT 'Investigadores/Escrivaes', COUNT(*)
FROM investigador_escrivao;
