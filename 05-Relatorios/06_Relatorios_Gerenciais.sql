-- =====================================================================
-- PoliceGOV - RELATORIOS GERENCIAIS (R01, R02 e R03)
-- Arquivo : 06_Relatorios_Gerenciais.sql
-- SGBD    : MySQL 8.0+ (compativel com ONLY_FULL_GROUP_BY)
-- Executar apos os scripts 01 a 05.
-- =====================================================================
USE policegov;

-- ---------------------------------------------------------------------
-- RELATORIO 01: quantidade de BOs registrados por delegacia/municipio
-- Ordenado do maior para o menor total. O LEFT JOIN mantem na lista as
-- delegacias que ainda nao tem nenhum BO (total 0).
-- Resultado com o DML do grupo: delegacia 1 = 3, delegacia 2 = 2,
-- delegacia 3 = 1.
-- ---------------------------------------------------------------------
SELECT
    d.nome                    AS delegacia,
    d.municipio,
    COUNT(b.numero_protocolo) AS total_bos
FROM delegacia d
LEFT JOIN bo b ON b.id_delegacia = d.id_delegacia
GROUP BY d.id_delegacia, d.nome, d.municipio
ORDER BY total_bos DESC, d.nome;

-- ---------------------------------------------------------------------
-- RELATORIO 02: incidencia de crimes tipificados no estado
-- Descricao do crime/artigo e total de vezes em que figurou em BOs.
-- Resultado com o DML do grupo: ART-147, ART-155-P4, ART-171-P2A e
-- ART-180 = 2 cada; ART-129 e ART-157-P2 = 1 cada.
-- ---------------------------------------------------------------------
SELECT
    t.codigo_artigo,
    t.descricao_tecnica        AS crime,
    COUNT(bt.numero_protocolo) AS total_ocorrencias
FROM tipo_ocorrencia t
LEFT JOIN bo_tipo bt ON bt.codigo_artigo = t.codigo_artigo
GROUP BY t.codigo_artigo, t.descricao_tecnica
ORDER BY total_ocorrencias DESC, t.codigo_artigo;

-- ---------------------------------------------------------------------
-- RELATORIO 03: inqueritos instaurados por delegado (somente ativos)
-- O delegado do inquerito e o que assinou o BO de origem.
-- Resultado com o DML do grupo: IP-2026/0101 e IP-2026/0104 (100001) e
-- IP-2026/0102 (100002). O IP-2026/0103 esta 'Relatado' e nao aparece.
-- ---------------------------------------------------------------------
SELECT
    p.matricula AS matricula_delegado,
    p.nome      AS nome_delegado,
    f.numero_inquerito,
    f.status_investigacao,
    f.data_instauracao,
    f.numero_protocolo_bo
FROM ficha_inquerito f
INNER JOIN bo b        ON b.numero_protocolo = f.numero_protocolo_bo
INNER JOIN delegado dg ON dg.matricula = b.matricula_delegado
INNER JOIN policial p  ON p.matricula = dg.matricula
WHERE f.status_investigacao = 'Ativo'
ORDER BY p.nome, f.data_instauracao;

-- ---------------------------------------------------------------------
-- CONFERENCIAS: as somas dos relatorios devem bater com as tabelas
-- ---------------------------------------------------------------------
SELECT (SELECT COUNT(*) FROM bo) AS total_bos_tabela,
       (SELECT SUM(x.total)
          FROM (SELECT COUNT(*) AS total FROM bo GROUP BY id_delegacia) x) AS soma_r01;

SELECT (SELECT COUNT(*) FROM bo_tipo) AS total_vinculos_tabela,
       (SELECT SUM(x.total)
          FROM (SELECT COUNT(*) AS total FROM bo_tipo GROUP BY codigo_artigo) x) AS soma_r02;
