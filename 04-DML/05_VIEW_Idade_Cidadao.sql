

-- 1. CRIACAO DA VIEW
-- A idade e calculada automaticamente a partir
-- da data de nascimento de cada cidadao.

CREATE OR REPLACE VIEW vw_idade_cidadao AS
SELECT
    cpf,
    nome,
    data_nascimento,

    EXTRACT(
        YEAR FROM AGE(CURRENT_DATE, data_nascimento)
    )::INT AS idade,

    CASE
        WHEN EXTRACT(
            YEAR FROM AGE(CURRENT_DATE, data_nascimento)
        ) < 18
            THEN 'Acionar Conselho Tutelar / ECA'

        WHEN EXTRACT(
            YEAR FROM AGE(CURRENT_DATE, data_nascimento)
        ) >= 60
            THEN 'Prioridade Estatuto do Idoso'

        ELSE 'Atendimento Padrão'
    END AS status_protecao

FROM cidadao;


-- 2. CONSULTA DAS IDADES
-- Mostra os cidadaos com suas idades atualizadas.

SELECT
    cpf,
    nome,
    data_nascimento,
    idade,
    status_protecao
FROM vw_idade_cidadao
ORDER BY idade;


-- 3. RELATORIO POR CLASSIFICACAO
-- Conta quantos cidadaos existem em cada categoria.

SELECT
    status_protecao,
    COUNT(*) AS total
FROM vw_idade_cidadao
GROUP BY status_protecao
ORDER BY status_protecao;


-- 4. CONFERENCIA DA ESTRUTURA
-- Verifica se a idade nao foi armazenada
-- diretamente na tabela cidadao.

SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'cidadao'
  AND column_name = 'idade';
