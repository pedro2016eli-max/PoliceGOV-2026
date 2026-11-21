-- =====================================================================
-- PoliceGOV - CONFERENCIA DOS DADOS
-- Arquivo : 08_Conferencia_Dados.sql
-- Somente consultas (nao altera dados). Executar apos os scripts 01 a 05.
-- =====================================================================
USE policegov;

-- ---------------------------------------------------------------------
-- 1. QUANTIDADES MINIMAS DO ENUNCIADO (todas as linhas devem ser 'OK')
-- ---------------------------------------------------------------------
SELECT 'Delegacias (municípios diferentes)' AS item, 3 AS minimo,
       COUNT(DISTINCT municipio) AS atual,
       IF(COUNT(DISTINCT municipio) >= 3, 'OK', 'FALTA') AS situacao
FROM delegacia
UNION ALL
SELECT 'Policiais', 4, COUNT(*), IF(COUNT(*) >= 4, 'OK', 'FALTA') FROM policial
UNION ALL
SELECT 'Delegados', 2, COUNT(*), IF(COUNT(*) >= 2, 'OK', 'FALTA') FROM delegado
UNION ALL
SELECT 'Investigadores/Escrivães', 2, COUNT(*), IF(COUNT(*) >= 2, 'OK', 'FALTA') FROM investigador_escrivao
UNION ALL
SELECT 'Cidadãos', 5, COUNT(*), IF(COUNT(*) >= 5, 'OK', 'FALTA') FROM cidadao
UNION ALL
SELECT 'Tipos de ocorrência', 4, COUNT(*), IF(COUNT(*) >= 4, 'OK', 'FALTA') FROM tipo_ocorrencia
UNION ALL
SELECT 'Boletins de Ocorrência', 5, COUNT(*), IF(COUNT(*) >= 5, 'OK', 'FALTA') FROM bo
UNION ALL
SELECT 'Vínculos BO x Tipo (N:N)', 8, COUNT(*), IF(COUNT(*) >= 8, 'OK', 'FALTA') FROM bo_tipo
UNION ALL
SELECT 'Fichas de Inquérito', 3, COUNT(*), IF(COUNT(*) >= 3, 'OK', 'FALTA') FROM ficha_inquerito;

-- ---------------------------------------------------------------------
-- 2. REGISTROS SEM VINCULO (todas as consultas devem retornar 0 linhas)
-- ---------------------------------------------------------------------

-- 2.1 BO sem nenhum cidadao envolvido ou sem nenhum tipo de ocorrencia
SELECT b.numero_protocolo, 'BO sem cidadão envolvido' AS problema
FROM bo b
LEFT JOIN bo_cidadao bc ON bc.numero_protocolo = b.numero_protocolo
WHERE bc.cpf IS NULL
UNION ALL
SELECT b.numero_protocolo, 'BO sem tipo de ocorrência'
FROM bo b
LEFT JOIN bo_tipo bt ON bt.numero_protocolo = b.numero_protocolo
WHERE bt.codigo_artigo IS NULL;

-- 2.2 Cidadao que nao aparece em nenhum BO
SELECT c.cpf, c.nome
FROM cidadao c
LEFT JOIN bo_cidadao bc ON bc.cpf = c.cpf
WHERE bc.numero_protocolo IS NULL;

-- 2.3 Policiais fora da especializacao total/disjunta
SELECT p.matricula, p.nome,
       CASE WHEN dg.matricula IS NULL AND ie.matricula IS NULL
            THEN 'Sem especialização (viola total)'
            ELSE 'Delegado e Investigador/Escrivão ao mesmo tempo (viola disjunta)' END AS problema
FROM policial p
LEFT JOIN delegado dg ON dg.matricula = p.matricula
LEFT JOIN investigador_escrivao ie ON ie.matricula = p.matricula
WHERE (dg.matricula IS NULL AND ie.matricula IS NULL)
   OR (dg.matricula IS NOT NULL AND ie.matricula IS NOT NULL);

-- ---------------------------------------------------------------------
-- 3. COBERTURA DOS DADOS PARA A VIEW E PARA OS RELATORIOS
-- ---------------------------------------------------------------------

-- 3.1 A view precisa ter ao menos um menor e um idoso (esperado >= 1 em ambos)
SELECT
    SUM(idade < 18)  AS menores_de_18,
    SUM(idade >= 60) AS idosos_60_ou_mais
FROM vw_idade_cidadao;

-- 3.2 Relatorio 03: inqueritos ativos por delegado (esperado >= 1 linha)
SELECT dg.matricula, COUNT(*) AS inqueritos_ativos
FROM ficha_inquerito f
JOIN bo b ON b.numero_protocolo = f.numero_protocolo_bo
JOIN delegado dg ON dg.matricula = b.matricula_delegado
WHERE f.status_investigacao = 'Ativo'
GROUP BY dg.matricula;

-- 3.3 Relatorio 01: delegacias sem nenhum BO (informativo)
SELECT d.id_delegacia, d.nome, d.municipio
FROM delegacia d
LEFT JOIN bo b ON b.id_delegacia = d.id_delegacia
WHERE b.numero_protocolo IS NULL;

-- 3.4 Relatorio 02: tipos de ocorrencia nunca usados (informativo)
SELECT t.codigo_artigo, t.descricao_tecnica
FROM tipo_ocorrencia t
LEFT JOIN bo_tipo bt ON bt.codigo_artigo = t.codigo_artigo
WHERE bt.numero_protocolo IS NULL;

-- ---------------------------------------------------------------------
-- 4. BO assinado por delegado lotado em OUTRA delegacia (informativo)
-- O minimundo nao proibe essa situacao.
-- ---------------------------------------------------------------------
SELECT b.numero_protocolo, b.id_delegacia AS delegacia_do_bo,
       b.matricula_delegado, p.id_delegacia AS delegacia_de_lotacao
FROM bo b
JOIN policial p ON p.matricula = b.matricula_delegado
WHERE b.id_delegacia <> p.id_delegacia;
