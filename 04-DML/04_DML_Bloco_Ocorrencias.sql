-- =====================================================================
-- PoliceGOV - DML do bloco Ocorrencias
-- Arquivo : 04_DML_Bloco_Ocorrencias.sql
-- Executar apos o 03_DML_Estrutura_Policial.sql (os BOs usam as
-- delegacias 1, 2 e 3 e os delegados 100001 e 100002).
-- Minimos do enunciado: 5 cidadaos, 4 tipos de ocorrencia, 5 BOs,
-- 8 vinculos BO x tipo e 3 fichas de inquerito.
-- =====================================================================
USE policegov;

-- ---------------------------------------------------------------------
-- 1. CIDADAOS
-- ---------------------------------------------------------------------
INSERT INTO cidadao (cpf, nome, data_nascimento, email) VALUES
('12345678901', 'Carlos Eduardo Mendes da Silva', '1985-04-12', 'carlos.mendes@email.com'),
('23456789012', 'Mariana Alves de Souza',         '1992-09-25', 'mariana.alves@email.com'),
('34567890123', 'Antônio Ferreira Lima',          '1958-11-03', 'antonio.lima@email.com'),  -- idoso
('45678901234', 'Lucas Gabriel Rocha',            '2011-07-19', 'resp.lucas@email.com'),    -- menor de idade
('56789012345', 'Fernanda Costa Oliveira',        '1999-02-14', 'fernanda.costa@email.com'),
('67890123456', 'Roberto Carlos Vasconcelos',     '1976-08-30', 'roberto.vasc@email.com');

-- ---------------------------------------------------------------------
-- 2. TIPOS DE OCORRENCIA PENAL
-- ---------------------------------------------------------------------
INSERT INTO tipo_ocorrencia (codigo_artigo, descricao_tecnica) VALUES
('CP-ART-155-P4',  'Furto Qualificado mediante rompimento de obstáculo ou concurso de pessoas'),
('CP-ART-171-P2A', 'Estelionato Virtual / Fraude Eletrônica'),
('CP-ART-157-P2',  'Roubo Majorado pelo emprego de arma de fogo'),
('CP-ART-129',     'Lesão Corporal Dolosa'),
('CP-ART-147',     'Ameaça'),
('CP-ART-180',     'Receptação de Bens Subtraídos');

-- ---------------------------------------------------------------------
-- 3. BOLETINS DE OCORRENCIA
-- ---------------------------------------------------------------------
INSERT INTO bo (numero_protocolo, data_hora_fato, descricao_narrativa, data_registro, status, id_delegacia, matricula_delegado) VALUES
('BO-2026/0001', '2026-10-10 14:30:00', 'Vítima relata subtração de notebook e smartphone mediante arrombamento da porta lateral da residência.', '2026-10-10 16:15:00', 'Em Investigação', 1, '100001'),
('BO-2026/0002', '2026-10-12 09:00:00', 'Comunicante transferiu R$ 4.500,00 via PIX após clonagem de perfil de aplicativo de mensagens.', '2026-10-12 11:20:00', 'Em Investigação', 1, '100001'),
('BO-2026/0003', '2026-10-15 21:45:00', 'Abordagem em via pública por dois indivíduos armados que subtraíram motocicleta e carteira.', '2026-10-15 22:30:00', 'Em Investigação', 2, '100002'),
('BO-2026/0004', '2026-10-18 17:10:00', 'Desentendimento entre vizinhos resultou em agressões físicas leves e ameaças verbais graves.', '2026-10-18 18:00:00', 'Concluído', 3, '100002'),
('BO-2026/0005', '2026-10-20 10:00:00', 'Representante legal registra furto de bicicleta dentro de condomínio e posterior anúncio em site de vendas.', '2026-10-20 14:05:00', 'Em Investigação', 1, '100001'),
('BO-2026/0006', '2026-10-22 19:20:00', 'Fraude bancária seguida de compras não reconhecidas em cartão virtual.', '2026-10-23 08:40:00', 'Arquivado', 2, '100002');

-- ---------------------------------------------------------------------
-- 4. ENVOLVIDOS NOS BOs (N:N entre BO e cidadao)
-- ---------------------------------------------------------------------
INSERT INTO bo_cidadao (numero_protocolo, cpf) VALUES
('BO-2026/0001', '12345678901'),
('BO-2026/0002', '34567890123'),
('BO-2026/0003', '23456789012'),
('BO-2026/0004', '56789012345'),
('BO-2026/0004', '67890123456'),
('BO-2026/0005', '45678901234'),
('BO-2026/0006', '67890123456');

-- ---------------------------------------------------------------------
-- 5. VINCULOS N:N ENTRE BO E TIPO_OCORRENCIA
-- ---------------------------------------------------------------------
INSERT INTO bo_tipo (numero_protocolo, codigo_artigo, observacao_tipificacao) VALUES
('BO-2026/0001', 'CP-ART-155-P4',  'Arrombamento constatado pela perícia preliminar'),
('BO-2026/0001', 'CP-ART-180',     'Suspeita de repasse imediato dos eletrônicos a receptador local'),
('BO-2026/0002', 'CP-ART-171-P2A', 'Engenharia social via aplicativo de mensagens contra pessoa idosa'),
('BO-2026/0003', 'CP-ART-157-P2',  'Emprego ostensivo de arma de fogo e concurso de agentes'),
('BO-2026/0003', 'CP-ART-147',     'Grave ameaça de morte proferida durante a subtração'),
('BO-2026/0004', 'CP-ART-129',     'Escoriações no braço esquerdo encaminhadas para exame de corpo de delito'),
('BO-2026/0004', 'CP-ART-147',     'Ameaças registradas em áudio de aplicativo'),
('BO-2026/0005', 'CP-ART-155-P4',  'Subtração mediante escalada de muro residencial'),
('BO-2026/0005', 'CP-ART-180',     'Bem localizado anunciado por terceiro em plataforma digital'),
('BO-2026/0006', 'CP-ART-171-P2A', 'Invasão de credenciais bancárias');

-- ---------------------------------------------------------------------
-- 6. FICHAS DE INQUERITO POLICIAL
-- ---------------------------------------------------------------------
INSERT INTO ficha_inquerito (numero_inquerito, data_instauracao, status_investigacao, numero_protocolo_bo) VALUES
('IP-2026/0101', '2026-10-11', 'Ativo',    'BO-2026/0001'),
('IP-2026/0102', '2026-10-16', 'Ativo',    'BO-2026/0003'),
('IP-2026/0103', '2026-10-19', 'Relatado', 'BO-2026/0004'),
('IP-2026/0104', '2026-10-21', 'Ativo',    'BO-2026/0005');

-- ---------------------------------------------------------------------
-- Conferencia
-- ---------------------------------------------------------------------
SELECT 'cidadao' AS tabela, COUNT(*) AS total FROM cidadao
UNION ALL SELECT 'tipo_ocorrencia', COUNT(*) FROM tipo_ocorrencia
UNION ALL SELECT 'bo', COUNT(*) FROM bo
UNION ALL SELECT 'bo_cidadao', COUNT(*) FROM bo_cidadao
UNION ALL SELECT 'bo_tipo', COUNT(*) FROM bo_tipo
UNION ALL SELECT 'ficha_inquerito', COUNT(*) FROM ficha_inquerito;
