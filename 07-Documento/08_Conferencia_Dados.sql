-- PoliceGOV | Conferencia de dados | PostgreSQL
-- Conecte-se ao banco policegov; executar apos scripts 01 a 05.
-- Somente SELECTs: nao altera registros.

-- 1. Quantidades minimas (esperado: todas as linhas OK).
WITH contagens(item, minimo, atual) AS (
    SELECT 'Delegacias (municipios diferentes)', 3, COUNT(DISTINCT municipio) FROM delegacia
    UNION ALL SELECT 'Policiais', 4, COUNT(*) FROM policial
    UNION ALL SELECT 'Delegados', 2, COUNT(*) FROM delegado
    UNION ALL SELECT 'Investigadores/Escrivaes', 2, COUNT(*) FROM investigador_escrivao
    UNION ALL SELECT 'Cidadaos', 5, COUNT(*) FROM cidadao
    UNION ALL SELECT 'Tipos de ocorrencia', 4, COUNT(*) FROM tipo_ocorrencia
    UNION ALL SELECT 'Boletins de ocorrencia', 5, COUNT(*) FROM bo
    UNION ALL SELECT 'Vinculos BO x Tipo (N:N)', 8, COUNT(*) FROM bo_tipo
    UNION ALL SELECT 'Fichas de inquerito', 3, COUNT(*) FROM ficha_inquerito
)
SELECT item, minimo, atual,
       CASE WHEN atual >= minimo THEN 'OK' ELSE 'FALTA' END AS situacao
FROM contagens;

-- 2.1 BO sem cidadao ou tipo (esperado: 0 linhas).
SELECT b.numero_protocolo, 'BO sem cidadao envolvido' AS problema
FROM bo b LEFT JOIN bo_cidadao bc ON bc.numero_protocolo = b.numero_protocolo
WHERE bc.cpf IS NULL
UNION ALL
SELECT b.numero_protocolo, 'BO sem tipo de ocorrencia'
FROM bo b LEFT JOIN bo_tipo bt ON bt.numero_protocolo = b.numero_protocolo
WHERE bt.codigo_artigo IS NULL;

-- 2.2 Cidadao nao vinculado a BO (esperado: 0 linhas).
SELECT c.cpf, c.nome
FROM cidadao c LEFT JOIN bo_cidadao bc ON bc.cpf = c.cpf
WHERE bc.numero_protocolo IS NULL;

-- 2.3 Especializacao total/disjunta (esperado: 0 linhas).
SELECT p.matricula, p.nome,
       CASE WHEN dg.matricula IS NULL THEN 'Sem especializacao'
            ELSE 'Em dois subtipos' END AS problema
FROM policial p
LEFT JOIN delegado dg ON dg.matricula = p.matricula
LEFT JOIN investigador_escrivao ie ON ie.matricula = p.matricula
WHERE (dg.matricula IS NULL AND ie.matricula IS NULL)
   OR (dg.matricula IS NOT NULL AND ie.matricula IS NOT NULL);

-- 3.1 Faixas etarias da VIEW (esperado: pelo menos 1 em cada).
SELECT COUNT(*) FILTER (WHERE idade < 18) AS menores_de_18,
       COUNT(*) FILTER (WHERE idade >= 60) AS idosos_60_ou_mais
FROM vw_idade_cidadao;

-- 3.2 Inqueritos ativos por delegado.
SELECT dg.matricula, COUNT(*) AS inqueritos_ativos
FROM ficha_inquerito f
JOIN bo b ON b.numero_protocolo = f.numero_protocolo_bo
JOIN delegado dg ON dg.matricula = b.matricula_delegado
WHERE f.status_investigacao = 'Ativo'
GROUP BY dg.matricula;

-- 3.3 Delegacias sem BO (informativo).
SELECT d.id_delegacia, d.nome, d.municipio
FROM delegacia d LEFT JOIN bo b ON b.id_delegacia = d.id_delegacia
WHERE b.numero_protocolo IS NULL;

-- 3.4 Tipos de ocorrencia nunca usados (informativo).
SELECT t.codigo_artigo, t.descricao_tecnica
FROM tipo_ocorrencia t LEFT JOIN bo_tipo bt ON bt.codigo_artigo = t.codigo_artigo
WHERE bt.numero_protocolo IS NULL;

-- 4. BO assinado por delegado lotado em outra delegacia (informativo).
SELECT b.numero_protocolo, b.id_delegacia AS delegacia_do_bo,
       b.matricula_delegado, p.id_delegacia AS delegacia_de_lotacao
FROM bo b JOIN policial p ON p.matricula = b.matricula_delegado
WHERE b.id_delegacia <> p.id_delegacia;
