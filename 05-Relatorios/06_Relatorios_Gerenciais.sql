-- PoliceGOV | Relatorios gerenciais | PostgreSQL
-- Conecte-se ao banco policegov no pgAdmin antes de executar.
-- Executar depois dos scripts 01 a 05.

-- R01: BOs por delegacia, inclusive delegacias sem BO.
SELECT d.nome AS delegacia, d.municipio,
       COUNT(b.numero_protocolo) AS total_bos
FROM delegacia d
LEFT JOIN bo b ON b.id_delegacia = d.id_delegacia
GROUP BY d.id_delegacia, d.nome, d.municipio
ORDER BY total_bos DESC, d.nome;

-- R02: incidencia de tipos de ocorrencia.
SELECT t.codigo_artigo, t.descricao_tecnica AS crime,
       COUNT(bt.numero_protocolo) AS total_ocorrencias
FROM tipo_ocorrencia t
LEFT JOIN bo_tipo bt ON bt.codigo_artigo = t.codigo_artigo
GROUP BY t.codigo_artigo, t.descricao_tecnica
ORDER BY total_ocorrencias DESC, t.codigo_artigo;

-- R03: inqueritos ativos por delegado responsavel pelo BO.
SELECT p.matricula AS matricula_delegado, p.nome AS nome_delegado,
       f.numero_inquerito, f.status_investigacao,
       f.data_instauracao, f.numero_protocolo_bo
FROM ficha_inquerito f
JOIN bo b ON b.numero_protocolo = f.numero_protocolo_bo
JOIN delegado dg ON dg.matricula = b.matricula_delegado
JOIN policial p ON p.matricula = dg.matricula
WHERE f.status_investigacao = 'Ativo'
ORDER BY p.nome, f.data_instauracao;

-- Conferencia dos totais (esperado com DML original: 6 e 10).
SELECT (SELECT COUNT(*) FROM bo) AS total_bos_tabela,
       (SELECT COALESCE(SUM(total), 0) FROM
           (SELECT COUNT(*) AS total FROM bo GROUP BY id_delegacia) x) AS soma_r01;
SELECT (SELECT COUNT(*) FROM bo_tipo) AS total_vinculos_tabela,
       (SELECT COALESCE(SUM(total), 0) FROM
           (SELECT COUNT(*) AS total FROM bo_tipo GROUP BY codigo_artigo) x) AS soma_r02;
