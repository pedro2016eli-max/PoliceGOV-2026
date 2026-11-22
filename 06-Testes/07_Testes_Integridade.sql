-- PoliceGOV | 39 testes de integridade | PostgreSQL
-- Executar APOS scripts 01 a 05, no banco policegov.
-- Os testes de restricao conferem o SQLSTATE retornado pelo banco.
-- Se uma regra nao funcionar, o teste aponta o problema.
-- Os testes com registros temporarios terminam com ROLLBACK.
-- Para repetir, mantenha os dados dos scripts 03 e 04.
-- T19 confere a estrutura sem recriar tabelas.

-- T01: matricula duplicada | SQLSTATE esperado: 23505
DO $teste$
BEGIN
  BEGIN
    INSERT INTO policial VALUES ('100001','Teste','t1@policia.gov.br','Investigador',1);
    RAISE EXCEPTION 'T01: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    RAISE NOTICE 'T01 OK: restricao aplicada';
  END;
END
$teste$;

-- T02: email duplicado | SQLSTATE esperado: 23505
DO $teste$
BEGIN
  BEGIN
    INSERT INTO policial VALUES ('300001','Teste','carlos.menezes@policia.gov.br','Investigador',1);
    RAISE EXCEPTION 'T02: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    RAISE NOTICE 'T02 OK: restricao aplicada';
  END;
END
$teste$;

-- T03: email invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO policial VALUES ('300002','Teste','invalido','Investigador',1);
    RAISE EXCEPTION 'T03: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T03 OK: restricao aplicada';
  END;
END
$teste$;

-- T04: cargo invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO policial VALUES ('300003','Teste','t4@policia.gov.br','Perito',1);
    RAISE EXCEPTION 'T04: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T04 OK: restricao aplicada';
  END;
END
$teste$;

-- T05: delegacia inexistente | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO policial VALUES ('300004','Teste','t5@policia.gov.br','Investigador',99);
    RAISE EXCEPTION 'T05: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T05 OK: restricao aplicada';
  END;
END
$teste$;

-- T06: telefone sem delegacia | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegacia_telefone VALUES (99,'8830001111');
    RAISE EXCEPTION 'T06: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T06 OK: restricao aplicada';
  END;
END
$teste$;

-- T07: telefone invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegacia_telefone VALUES (1,'abc123');
    RAISE EXCEPTION 'T07: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T07 OK: restricao aplicada';
  END;
END
$teste$;

-- T08: telefone duplicado | SQLSTATE esperado: 23505
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegacia_telefone VALUES (1,'8835719001');
    RAISE EXCEPTION 'T08: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    RAISE NOTICE 'T08 OK: restricao aplicada';
  END;
END
$teste$;

-- T09: CEP invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegacia (nome,municipio,logradouro,numero,bairro,cep,cidade) VALUES ('Teste 09','Crato','Rua A',10,'Centro','123','Crato');
    RAISE EXCEPTION 'T09: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T09 OK: restricao aplicada';
  END;
END
$teste$;

-- T10: numero negativo | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegacia (nome,municipio,logradouro,numero,bairro,cep,cidade) VALUES ('Teste 10','Crato','Rua A',-5,'Centro','63100000','Crato');
    RAISE EXCEPTION 'T10: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T10 OK: restricao aplicada';
  END;
END
$teste$;

-- T11: delegado sem portaria; dados temporarios revertidos.
BEGIN;
INSERT INTO policial VALUES ('100003','Delegado Teste','delegado.teste@policia.gov.br','Delegado de Polícia',3);
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegado (matricula,cargo,numero_portaria) VALUES ('100003','Delegado de Polícia',NULL);
    RAISE EXCEPTION 'T11: restricao nao aplicada';
  EXCEPTION WHEN SQLSTATE '23502' THEN RAISE NOTICE 'T11 OK';
  END;
END $teste$;
ROLLBACK;

-- T12: portaria duplicada; dados temporarios revertidos.
BEGIN;
INSERT INTO policial VALUES ('100003','Delegado Teste','delegado.teste@policia.gov.br','Delegado de Polícia',3);
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegado (matricula,cargo,numero_portaria) VALUES ('100003','Delegado de Polícia','PORT-SSPDS-2021/0147');
    RAISE EXCEPTION 'T12: restricao nao aplicada';
  EXCEPTION WHEN SQLSTATE '23505' THEN RAISE NOTICE 'T12 OK';
  END;
END $teste$;
ROLLBACK;

-- T13: investigador como delegado | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO delegado (matricula,cargo,numero_portaria) VALUES ('200001','Delegado de Polícia','PORT-TESTE-0001');
    RAISE EXCEPTION 'T13: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T13 OK: restricao aplicada';
  END;
END
$teste$;

-- T14: delegado como investigador | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO investigador_escrivao (matricula,cargo,area_atuacao) VALUES ('100001','Investigador','Homicidios');
    RAISE EXCEPTION 'T14: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T14 OK: restricao aplicada';
  END;
END
$teste$;

-- T15: investigador sem area de atuacao.
BEGIN;
INSERT INTO policial VALUES ('200003','Investigador Teste','inv.teste@policia.gov.br','Investigador',2);
DO $teste$
BEGIN
  BEGIN
    INSERT INTO investigador_escrivao (matricula,cargo,area_atuacao) VALUES ('200003','Investigador',NULL);
    RAISE EXCEPTION 'T15: restricao nao aplicada';
  EXCEPTION WHEN SQLSTATE '23502' THEN RAISE NOTICE 'T15 OK';
  END;
END $teste$;
ROLLBACK;

-- T16: excluir delegacia com policiais | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    DELETE FROM delegacia WHERE id_delegacia=1;
    RAISE EXCEPTION 'T16: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T16 OK: restricao aplicada';
  END;
END
$teste$;

-- T17: excluir policial delegado | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    DELETE FROM policial WHERE matricula='100001';
    RAISE EXCEPTION 'T17: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T17 OK: restricao aplicada';
  END;
END
$teste$;

-- T18: telefones excluidos em cascata (transacao revertida)
BEGIN;
INSERT INTO delegacia (nome,municipio,logradouro,numero,bairro,cep,cidade)
VALUES ('Delegacia Temporaria T18','Crato','Rua B',20,'Centro','63100000','Crato');
INSERT INTO delegacia_telefone (id_delegacia,telefone)
SELECT id_delegacia,'8835211000' FROM delegacia WHERE nome='Delegacia Temporaria T18';
DELETE FROM delegacia WHERE nome='Delegacia Temporaria T18';
DO $teste$ BEGIN
  IF EXISTS (SELECT 1 FROM delegacia_telefone WHERE telefone='8835211000') THEN
    RAISE EXCEPTION 'T18: telefone nao removido';
  END IF;
  RAISE NOTICE 'T18 OK';
END $teste$;
ROLLBACK;

-- T19: conferencia das tabelas criadas.
-- Nao executar DDL 01/02 no banco populado: eles contem DROP TABLE CASCADE.
-- Verificacao nao destrutiva de existencia das 12 tabelas esperadas.
DO $teste$
DECLARE total integer;
BEGIN
 SELECT COUNT(*) INTO total FROM information_schema.tables
 WHERE table_schema='public' AND table_type='BASE TABLE'
 AND table_name IN ('delegacia','delegacia_telefone','policial','delegado',
 'investigador_escrivao','cidadao','tipo_ocorrencia','bo','bo_cidadao',
 'bo_tipo','ficha_inquerito');
 IF total <> 11 THEN RAISE EXCEPTION 'T19: tabelas encontradas: %, esperado 11',total; END IF;
 RAISE NOTICE 'T19 OK: tabelas presentes';
END $teste$;

-- T20: especializacao total e disjunta dos dados atuais.
DO $teste$
BEGIN
 IF EXISTS (
  SELECT 1 FROM policial p
  LEFT JOIN delegado d ON d.matricula=p.matricula
  LEFT JOIN investigador_escrivao i ON i.matricula=p.matricula
  WHERE (d.matricula IS NULL AND i.matricula IS NULL)
     OR (d.matricula IS NOT NULL AND i.matricula IS NOT NULL)
 ) THEN RAISE EXCEPTION 'T20: especializacao inconsistente'; END IF;
 RAISE NOTICE 'T20 OK';
END $teste$;

-- T21: CPF invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO cidadao (cpf,nome,data_nascimento,email) VALUES ('123','Teste','1990-01-01','teste@email.com');
    RAISE EXCEPTION 'T21: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T21 OK: restricao aplicada';
  END;
END
$teste$;

-- T22: email cidadao invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO cidadao (cpf,nome,data_nascimento,email) VALUES ('88888888801','Teste','1990-01-01','semarroba');
    RAISE EXCEPTION 'T22: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T22 OK: restricao aplicada';
  END;
END
$teste$;

-- T23: data registro anterior ao fato | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo (numero_protocolo,data_hora_fato,descricao_narrativa,data_registro,status,id_delegacia,matricula_delegado) VALUES ('BO-2026/9999','2026-10-25 15:00:00','Teste 23','2026-10-25 10:00:00','Em Investigação',1,'100001');
    RAISE EXCEPTION 'T23: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T23 OK: restricao aplicada';
  END;
END
$teste$;

-- T24: BO delegacia inexistente | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo (numero_protocolo,data_hora_fato,descricao_narrativa,data_registro,status,id_delegacia,matricula_delegado) VALUES ('BO-2026/9998','2026-10-25 10:00:00','Teste 24','2026-10-25 11:00:00','Em Investigação',99,'100001');
    RAISE EXCEPTION 'T24: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T24 OK: restricao aplicada';
  END;
END
$teste$;

-- T25: BO assinado por investigador | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo (numero_protocolo,data_hora_fato,descricao_narrativa,data_registro,status,id_delegacia,matricula_delegado) VALUES ('BO-2026/9997','2026-10-25 10:00:00','Teste 25','2026-10-25 11:00:00','Em Investigação',1,'200001');
    RAISE EXCEPTION 'T25: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T25 OK: restricao aplicada';
  END;
END
$teste$;

-- T26: status invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo (numero_protocolo,data_hora_fato,descricao_narrativa,data_registro,status,id_delegacia,matricula_delegado) VALUES ('BO-2026/9996','2026-10-25 10:00:00','Teste 26','2026-10-25 11:00:00','Perdido',1,'100001');
    RAISE EXCEPTION 'T26: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T26 OK: restricao aplicada';
  END;
END
$teste$;

-- T27: cidadao duplicado em BO | SQLSTATE esperado: 23505
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo_cidadao VALUES ('BO-2026/0001','12345678901');
    RAISE EXCEPTION 'T27: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    RAISE NOTICE 'T27 OK: restricao aplicada';
  END;
END
$teste$;

-- T28: CPF inexistente em BO | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo_cidadao VALUES ('BO-2026/0001','00000000000');
    RAISE EXCEPTION 'T28: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T28 OK: restricao aplicada';
  END;
END
$teste$;

-- T29: tipo duplicado em BO | SQLSTATE esperado: 23505
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo_tipo (numero_protocolo,codigo_artigo) VALUES ('BO-2026/0001','CP-ART-155-P4');
    RAISE EXCEPTION 'T29: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    RAISE NOTICE 'T29 OK: restricao aplicada';
  END;
END
$teste$;

-- T30: tipo inexistente | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    INSERT INTO bo_tipo (numero_protocolo,codigo_artigo) VALUES ('BO-2026/0001','CP-ART-999');
    RAISE EXCEPTION 'T30: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T30 OK: restricao aplicada';
  END;
END
$teste$;

-- T31: segunda ficha para mesmo BO | SQLSTATE esperado: 23505
DO $teste$
BEGIN
  BEGIN
    INSERT INTO ficha_inquerito (numero_inquerito,data_instauracao,status_investigacao,numero_protocolo_bo) VALUES ('IP-2026/9999','2026-10-25','Ativo','BO-2026/0001');
    RAISE EXCEPTION 'T31: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23505' THEN
    RAISE NOTICE 'T31 OK: restricao aplicada';
  END;
END
$teste$;

-- T32: data inquerito antiga | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO ficha_inquerito (numero_inquerito,data_instauracao,status_investigacao,numero_protocolo_bo) VALUES ('IP-1999/0001','1999-12-31','Ativo','BO-2026/0002');
    RAISE EXCEPTION 'T32: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T32 OK: restricao aplicada';
  END;
END
$teste$;

-- T33: status inquerito invalido | SQLSTATE esperado: 23514
DO $teste$
BEGIN
  BEGIN
    INSERT INTO ficha_inquerito (numero_inquerito,data_instauracao,status_investigacao,numero_protocolo_bo) VALUES ('IP-2026/9998','2026-10-25','Perdido','BO-2026/0002');
    RAISE EXCEPTION 'T33: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23514' THEN
    RAISE NOTICE 'T33 OK: restricao aplicada';
  END;
END
$teste$;

-- T34: excluir BO com inquerito | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    DELETE FROM bo WHERE numero_protocolo='BO-2026/0001';
    RAISE EXCEPTION 'T34: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T34 OK: restricao aplicada';
  END;
END
$teste$;

-- T35: excluir cidadao vinculado | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    DELETE FROM cidadao WHERE cpf='12345678901';
    RAISE EXCEPTION 'T35: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T35 OK: restricao aplicada';
  END;
END
$teste$;

-- T36: excluir tipo utilizado | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    DELETE FROM tipo_ocorrencia WHERE codigo_artigo='CP-ART-129';
    RAISE EXCEPTION 'T36: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T36 OK: restricao aplicada';
  END;
END
$teste$;

-- T37: excluir delegado com BO | SQLSTATE esperado: 23503
DO $teste$
BEGIN
  BEGIN
    DELETE FROM delegado WHERE matricula='100001';
    RAISE EXCEPTION 'T37: operacao indevida foi aceita';
  EXCEPTION WHEN SQLSTATE '23503' THEN
    RAISE NOTICE 'T37 OK: restricao aplicada';
  END;
END
$teste$;

-- T38: BO excluido em cascata (transacao revertida)
BEGIN;
INSERT INTO bo (numero_protocolo,data_hora_fato,descricao_narrativa,data_registro,status,id_delegacia,matricula_delegado) VALUES ('BO-2026/9001','2026-10-25 10:00:00','Teste 38','2026-10-25 11:00:00','Em Investigação',1,'100001');
INSERT INTO bo_cidadao VALUES ('BO-2026/9001','12345678901');
INSERT INTO bo_tipo (numero_protocolo,codigo_artigo) VALUES ('BO-2026/9001','CP-ART-147');
DELETE FROM bo WHERE numero_protocolo='BO-2026/9001';
DO $teste$ BEGIN
 IF EXISTS (SELECT 1 FROM bo_cidadao WHERE numero_protocolo='BO-2026/9001')
 OR EXISTS (SELECT 1 FROM bo_tipo WHERE numero_protocolo='BO-2026/9001') THEN
 RAISE EXCEPTION 'T38: vinculos remanescentes'; END IF;
 RAISE NOTICE 'T38 OK';
END $teste$;
ROLLBACK;

-- T39: idades de fronteira 17, 18, 59 e 60 (transacao revertida)
BEGIN;
INSERT INTO cidadao (cpf,nome,data_nascimento,email) VALUES
('99999999901','TESTE 17',CURRENT_DATE-INTERVAL '18 years'+INTERVAL '1 day','teste17@email.com'),
('99999999902','TESTE 18',CURRENT_DATE-INTERVAL '18 years','teste18@email.com'),
('99999999903','TESTE 59',CURRENT_DATE-INTERVAL '60 years'+INTERVAL '1 day','teste59@email.com'),
('99999999904','TESTE 60',CURRENT_DATE-INTERVAL '60 years','teste60@email.com');
DO $teste$ BEGIN
 IF (SELECT COUNT(*) FROM vw_idade_cidadao
     WHERE (cpf='99999999901' AND idade=17 AND status_protecao='Acionar Conselho Tutelar / ECA')
        OR (cpf='99999999902' AND idade=18 AND status_protecao='Atendimento Padrão')
        OR (cpf='99999999903' AND idade=59 AND status_protecao='Atendimento Padrão')
        OR (cpf='99999999904' AND idade=60 AND status_protecao='Prioridade Estatuto do Idoso')) <> 4
 THEN RAISE EXCEPTION 'T39: faixa etaria incorreta'; END IF;
 RAISE NOTICE 'T39 OK';
END $teste$;
ROLLBACK;

-- Conferencia final: dados-base preservados (esperado 4, 6, 6).
SELECT (SELECT COUNT(*) FROM policial) AS policiais,
       (SELECT COUNT(*) FROM cidadao) AS cidadaos,
       (SELECT COUNT(*) FROM bo) AS boletins;
