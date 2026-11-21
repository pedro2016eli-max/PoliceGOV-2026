-- =====================================================================
-- PoliceGOV - TESTES DE INTEGRIDADE E REGRAS DE NEGOCIO
-- Arquivo : 07_Testes_Integridade.sql
-- Pre-requisito: scripts 01 a 05 executados.
-- Executar um teste por vez (o Workbench para no primeiro erro).
-- Os testes "ERRO ESPERADO" devem falhar; os "OK ESPERADO" devem
-- funcionar. A limpeza final remove os dados de teste.
-- =====================================================================
USE policegov;

-- =====================================================================
-- PARTE 1 - ESTRUTURA POLICIAL
-- =====================================================================

-- T01: matricula duplicada (PK)
-- ERRO ESPERADO: 1062 Duplicate entry '100001'
INSERT INTO policial VALUES
 ('100001','Fulano Teste','fulano@policia.gov.br','Investigador',1);

-- T02: e-mail duplicado (UNIQUE)
-- ERRO ESPERADO: 1062 Duplicate entry ... uq_policial_email
INSERT INTO policial VALUES
 ('300001','Fulano Teste','carlos.menezes@policia.gov.br','Investigador',1);

-- T03: e-mail com formato invalido (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_policial_email' is violated
INSERT INTO policial VALUES
 ('300002','Fulano Teste','emailinvalido','Investigador',1);

-- T04: cargo fora do dominio (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_policial_cargo' is violated
INSERT INTO policial VALUES
 ('300003','Fulano Teste','fulano3@policia.gov.br','Perito',1);

-- T05: policial em delegacia inexistente (FK)
-- ERRO ESPERADO: 1452 Cannot add or update a child row (fk_policial_delegacia)
INSERT INTO policial VALUES
 ('300004','Fulano Teste','fulano4@policia.gov.br','Investigador',99);

-- T06: telefone para delegacia inexistente (FK)
-- ERRO ESPERADO: 1452 (fk_telefone_delegacia)
INSERT INTO delegacia_telefone VALUES (99, '8830001111');

-- T07: telefone com formato invalido (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_telefone_formato' is violated
INSERT INTO delegacia_telefone VALUES (1, 'abc123');

-- T08: telefone repetido na mesma delegacia (PK composta)
-- ERRO ESPERADO: 1062 Duplicate entry '1-8835719001'
INSERT INTO delegacia_telefone VALUES (1, '8835719001');

-- T09: CEP invalido (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_delegacia_cep' is violated
INSERT INTO delegacia (nome, municipio, logradouro, numero, bairro, cep, cidade)
VALUES ('Delegacia Teste','Crato','Rua A',10,'Centro','123','Crato');

-- T10: numero do endereco negativo (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_delegacia_numero' is violated
INSERT INTO delegacia (nome, municipio, logradouro, numero, bairro, cep, cidade)
VALUES ('Delegacia Teste 2','Crato','Rua A',-5,'Centro','63100000','Crato');

-- T11: delegado sem portaria (NOT NULL)
-- Primeiro cria um policial com cargo de delegado (OK ESPERADO):
INSERT INTO policial VALUES
 ('100003','Delegado Teste','delegado.teste@policia.gov.br','Delegado de Polícia',3);
-- ERRO ESPERADO: 1048 Column 'numero_portaria' cannot be null
INSERT INTO delegado (matricula, cargo, numero_portaria)
VALUES ('100003','Delegado de Polícia', NULL);

-- T12: portaria duplicada (UNIQUE)
-- ERRO ESPERADO: 1062 Duplicate entry ... uq_delegado_portaria
INSERT INTO delegado (matricula, cargo, numero_portaria)
VALUES ('100003','Delegado de Polícia','PORT-SSPDS-2021/0147');

-- T13: investigador cadastrado como delegado
-- ERRO ESPERADO: 1452 (fk_delegado_policial) - a matricula 200001 tem cargo 'Investigador'
INSERT INTO delegado (matricula, cargo, numero_portaria)
VALUES ('200001','Delegado de Polícia','PORT-TESTE-0001');

-- T14: delegado cadastrado como investigador
-- ERRO ESPERADO: 1452 (fk_inv_esc_policial)
INSERT INTO investigador_escrivao (matricula, cargo, area_atuacao)
VALUES ('100001','Investigador','Homicidios');

-- T15: investigador sem area de atuacao (NOT NULL)
-- Cria o policial (OK ESPERADO):
INSERT INTO policial VALUES
 ('200003','Investigador Teste','inv.teste@policia.gov.br','Investigador',2);
-- ERRO ESPERADO: 1048 Column 'area_atuacao' cannot be null
INSERT INTO investigador_escrivao (matricula, cargo, area_atuacao)
VALUES ('200003','Investigador', NULL);

-- T16: excluir delegacia que possui policiais (RESTRICT)
-- ERRO ESPERADO: 1451 Cannot delete or update a parent row (fk_policial_delegacia)
DELETE FROM delegacia WHERE id_delegacia = 1;

-- T17: excluir policial que e delegado (RESTRICT)
-- ERRO ESPERADO: 1451 (fk_delegado_policial)
DELETE FROM policial WHERE matricula = '100001';

-- T18: excluir delegacia sem policiais -> telefones removidos em cascata
-- OK ESPERADO: cria a delegacia 4 com telefone, exclui, e o telefone some junto.
INSERT INTO delegacia (id_delegacia, nome, municipio, logradouro, numero, bairro, cep, cidade)
VALUES (4,'Delegacia Temporaria','Crato','Rua B',20,'Centro','63100000','Crato');
INSERT INTO delegacia_telefone VALUES (4,'8835211000');
DELETE FROM delegacia WHERE id_delegacia = 4;
SELECT * FROM delegacia_telefone WHERE id_delegacia = 4;   -- deve retornar 0 linhas

-- T19: reexecucao do script 01_DDL_Estrutura_Policial.sql
-- Rodar o script duas vezes seguidas nao pode gerar erro.

-- T20: especializacao total e disjunta
-- Esperado: nenhuma linha (todo policial esta em exatamente um subtipo)
SELECT p.matricula, p.nome
FROM policial p
LEFT JOIN delegado dg ON dg.matricula = p.matricula
LEFT JOIN investigador_escrivao ie ON ie.matricula = p.matricula
WHERE (dg.matricula IS NULL AND ie.matricula IS NULL)
   OR (dg.matricula IS NOT NULL AND ie.matricula IS NOT NULL);

-- =====================================================================
-- PARTE 2 - BLOCO DE OCORRENCIAS
-- =====================================================================

-- T21: CPF com formato invalido (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_cidadao_cpf' is violated
INSERT INTO cidadao (cpf, nome, data_nascimento, email)
VALUES ('123', 'Cidadao Teste', '1990-01-01', 'teste@email.com');

-- T22: e-mail do cidadao com formato invalido (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_cidadao_email' is violated
INSERT INTO cidadao (cpf, nome, data_nascimento, email)
VALUES ('88888888801', 'Cidadao Teste', '1990-01-01', 'semarroba');

-- T23: BO com data de registro anterior ao fato (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_bo_datas' is violated
INSERT INTO bo (numero_protocolo, data_hora_fato, descricao_narrativa, data_registro, status, id_delegacia, matricula_delegado)
VALUES ('BO-2026/9999', '2026-10-25 15:00:00', 'Teste de erro temporal', '2026-10-25 10:00:00', 'Em Investigação', 1, '100001');

-- T24: BO em delegacia inexistente (FK)
-- ERRO ESPERADO: 1452 (fk_bo_delegacia)
INSERT INTO bo (numero_protocolo, data_hora_fato, descricao_narrativa, data_registro, status, id_delegacia, matricula_delegado)
VALUES ('BO-2026/9998', '2026-10-25 10:00:00', 'Teste de delegacia inexistente', '2026-10-25 11:00:00', 'Em Investigação', 99, '100001');

-- T25: BO assinado por policial que nao e delegado (FK)
-- ERRO ESPERADO: 1452 (fk_bo_delegado) - a matricula 200001 e de investigador
INSERT INTO bo (numero_protocolo, data_hora_fato, descricao_narrativa, data_registro, status, id_delegacia, matricula_delegado)
VALUES ('BO-2026/9997', '2026-10-25 10:00:00', 'Teste de assinatura indevida', '2026-10-25 11:00:00', 'Em Investigação', 1, '200001');

-- T26: status do BO fora do dominio (ENUM)
-- ERRO ESPERADO: 1265 Data truncated for column 'status'
INSERT INTO bo (numero_protocolo, data_hora_fato, descricao_narrativa, data_registro, status, id_delegacia, matricula_delegado)
VALUES ('BO-2026/9996', '2026-10-25 10:00:00', 'Teste de status invalido', '2026-10-25 11:00:00', 'Perdido', 1, '100001');

-- T27: cidadao repetido no mesmo BO (PK composta)
-- ERRO ESPERADO: 1062 Duplicate entry 'BO-2026/0001-12345678901'
INSERT INTO bo_cidadao (numero_protocolo, cpf) VALUES ('BO-2026/0001', '12345678901');

-- T28: envolvido com CPF inexistente (FK)
-- ERRO ESPERADO: 1452 (fk_bocidadao_cidadao)
INSERT INTO bo_cidadao (numero_protocolo, cpf) VALUES ('BO-2026/0001', '00000000000');

-- T29: mesmo tipo de ocorrencia repetido no mesmo BO (PK composta)
-- ERRO ESPERADO: 1062 Duplicate entry 'BO-2026/0001-CP-ART-155-P4'
INSERT INTO bo_tipo (numero_protocolo, codigo_artigo) VALUES ('BO-2026/0001', 'CP-ART-155-P4');

-- T30: tipo de ocorrencia inexistente (FK)
-- ERRO ESPERADO: 1452 (fk_botipo_tipo)
INSERT INTO bo_tipo (numero_protocolo, codigo_artigo) VALUES ('BO-2026/0001', 'CP-ART-999');

-- T31: segunda ficha para o mesmo BO (UNIQUE - relacionamento 1:1)
-- ERRO ESPERADO: 1062 Duplicate entry 'BO-2026/0001' for key 'ficha_inquerito.uq_ficha_bo'
INSERT INTO ficha_inquerito (numero_inquerito, data_instauracao, status_investigacao, numero_protocolo_bo)
VALUES ('IP-2026/9999', '2026-10-25', 'Ativo', 'BO-2026/0001');

-- T32: ficha com data de instauracao muito antiga (CHECK)
-- ERRO ESPERADO: 3819 Check constraint 'ck_ficha_data' is violated
INSERT INTO ficha_inquerito (numero_inquerito, data_instauracao, status_investigacao, numero_protocolo_bo)
VALUES ('IP-1999/0001', '1999-12-31', 'Ativo', 'BO-2026/0002');

-- T33: ficha com status fora do dominio (ENUM)
-- ERRO ESPERADO: 1265 Data truncated for column 'status_investigacao'
INSERT INTO ficha_inquerito (numero_inquerito, data_instauracao, status_investigacao, numero_protocolo_bo)
VALUES ('IP-2026/9998', '2026-10-25', 'Perdido', 'BO-2026/0002');

-- T34: excluir BO que possui ficha de inquerito (RESTRICT)
-- ERRO ESPERADO: 1451 (fk_ficha_bo)
DELETE FROM bo WHERE numero_protocolo = 'BO-2026/0001';

-- T35: excluir cidadao envolvido em BO (RESTRICT)
-- ERRO ESPERADO: 1451 (fk_bocidadao_cidadao)
DELETE FROM cidadao WHERE cpf = '12345678901';

-- T36: excluir tipo de ocorrencia ja utilizado (RESTRICT)
-- ERRO ESPERADO: 1451 (fk_botipo_tipo)
DELETE FROM tipo_ocorrencia WHERE codigo_artigo = 'CP-ART-129';

-- T37: excluir delegado que assinou BOs (RESTRICT)
-- ERRO ESPERADO: 1451 (fk_bo_delegado)
DELETE FROM delegado WHERE matricula = '100001';

-- T38: excluir BO sem ficha -> vinculos removidos em cascata
-- OK ESPERADO: as duas ultimas consultas retornam 0
INSERT INTO bo (numero_protocolo, data_hora_fato, descricao_narrativa, data_registro, status, id_delegacia, matricula_delegado)
VALUES ('BO-2026/9001', '2026-10-25 10:00:00', 'BO temporario de teste', '2026-10-25 11:00:00', 'Em Investigação', 1, '100001');
INSERT INTO bo_cidadao (numero_protocolo, cpf) VALUES ('BO-2026/9001', '12345678901');
INSERT INTO bo_tipo (numero_protocolo, codigo_artigo) VALUES ('BO-2026/9001', 'CP-ART-147');
DELETE FROM bo WHERE numero_protocolo = 'BO-2026/9001';
SELECT COUNT(*) AS cidadaos_restantes FROM bo_cidadao WHERE numero_protocolo = 'BO-2026/9001';
SELECT COUNT(*) AS tipos_restantes    FROM bo_tipo    WHERE numero_protocolo = 'BO-2026/9001';

-- T39: valores de fronteira da view de idade (17, 18, 59 e 60 anos)
-- Esperado: 17 -> Conselho Tutelar | 18 -> Padrao | 59 -> Padrao | 60 -> Idoso
INSERT INTO cidadao (cpf, nome, data_nascimento, email) VALUES
('99999999901', 'TESTE Fronteira 17 anos', DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 18 YEAR), INTERVAL 1 DAY), 'teste17@email.com'),
('99999999902', 'TESTE Fronteira 18 anos', DATE_SUB(CURDATE(), INTERVAL 18 YEAR), 'teste18@email.com'),
('99999999903', 'TESTE Fronteira 59 anos', DATE_ADD(DATE_SUB(CURDATE(), INTERVAL 60 YEAR), INTERVAL 1 DAY), 'teste59@email.com'),
('99999999904', 'TESTE Fronteira 60 anos', DATE_SUB(CURDATE(), INTERVAL 60 YEAR), 'teste60@email.com');

SELECT * FROM vw_idade_cidadao WHERE cpf LIKE '999999999%' ORDER BY idade;

-- =====================================================================
-- LIMPEZA DOS DADOS DE TESTE (OK ESPERADO)
-- =====================================================================
DELETE FROM cidadao WHERE cpf LIKE '999999999%';
DELETE FROM investigador_escrivao WHERE matricula = '200003';
DELETE FROM delegado WHERE matricula = '100003';
DELETE FROM policial WHERE matricula IN ('100003','200003');

SELECT COUNT(*) AS policiais_restantes FROM policial;                          -- deve ser 4
SELECT COUNT(*) AS cidadaos_restantes  FROM cidadao;                           -- deve ser 6
SELECT COUNT(*) AS bos_restantes       FROM bo;                                -- deve ser 6
