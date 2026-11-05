-- Entrega 2 - Modelo lógico e implementação MySQL 8.0+
-- Grupo: Arthur Costa, Felipe Pereira Vescia e Roginer Haiz dos Santos
-- Dados exclusivamente fictícios. O script é reexecutável em ambiente acadêmico.

DROP DATABASE IF EXISTS qore_entrega_2;
CREATE DATABASE qore_entrega_2 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE qore_entrega_2;

CREATE TABLE funcionario (
  id_funcionario BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  funcao VARCHAR(100) NOT NULL,
  email_corporativo VARCHAR(150) NULL,
  situacao VARCHAR(10) NOT NULL DEFAULT 'ATIVO',
  CONSTRAINT uq_funcionario_email UNIQUE (email_corporativo),
  CONSTRAINT ck_funcionario_situacao CHECK (situacao IN ('ATIVO','INATIVO'))
);

CREATE TABLE cliente (
  id_cliente BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome_empresarial VARCHAR(150) NOT NULL,
  identificacao_empresarial VARCHAR(30) NULL,
  email_contato VARCHAR(150) NULL,
  telefone_contato VARCHAR(20) NULL,
  endereco VARCHAR(255) NULL,
  cadastrado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  situacao VARCHAR(15) NOT NULL DEFAULT 'ATIVO',
  CONSTRAINT uq_cliente_identificacao UNIQUE (identificacao_empresarial),
  CONSTRAINT ck_cliente_situacao CHECK (situacao IN ('ATIVO','INATIVO'))
);

CREATE TABLE chamado (
  id_chamado BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente BIGINT UNSIGNED NOT NULL,
  id_projeto BIGINT UNSIGNED NULL,
  id_entrega BIGINT UNSIGNED NULL,
  id_responsavel BIGINT UNSIGNED NULL,
  solicitante VARCHAR(150) NOT NULL,
  tipo VARCHAR(20) NOT NULL DEFAULT 'SOLICITACAO',
  prioridade VARCHAR(10) NOT NULL DEFAULT 'MEDIA',
  descricao TEXT NOT NULL,
  aberto_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  prazo_em DATETIME NULL,
  situacao VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
  solucao TEXT NULL,
  encerrado_em DATETIME NULL,
  CONSTRAINT fk_chamado_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_chamado_responsavel FOREIGN KEY (id_responsavel) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_chamado_tipo CHECK (tipo IN ('SOLICITACAO','DUVIDA','INCIDENTE','CORRECAO','MELHORIA','SUPORTE')),
  CONSTRAINT ck_chamado_prioridade CHECK (prioridade IN ('BAIXA','MEDIA','ALTA','CRITICA')),
  CONSTRAINT ck_chamado_situacao CHECK (situacao IN ('ABERTO','EM_ANALISE','AGUARDANDO','EM_ATENDIMENTO','RESOLVIDO','ENCERRADO','CANCELADO')),
  CONSTRAINT ck_chamado_datas CHECK ((prazo_em IS NULL OR prazo_em >= aberto_em) AND (encerrado_em IS NULL OR encerrado_em >= aberto_em))
);

CREATE TABLE reuniao (
  id_reuniao BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_chamado BIGINT UNSIGNED NOT NULL,
  data_hora DATETIME NOT NULL,
  canal_local VARCHAR(150) NOT NULL,
  participantes_resumo TEXT NOT NULL,
  pauta TEXT NOT NULL,
  decisoes TEXT NULL,
  pendencias TEXT NULL,
  CONSTRAINT fk_reuniao_chamado FOREIGN KEY (id_chamado) REFERENCES chamado(id_chamado)
);

CREATE TABLE escopo (
  id_escopo BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_chamado BIGINT UNSIGNED NOT NULL,
  id_reuniao BIGINT UNSIGNED NOT NULL,
  versao VARCHAR(20) NOT NULL,
  requisitos TEXT NOT NULL,
  entregas_previstas TEXT NOT NULL,
  limites TEXT NULL,
  premissas TEXT NULL,
  prazo_estimado_dias INT UNSIGNED NOT NULL,
  situacao VARCHAR(20) NOT NULL DEFAULT 'EM_ELABORACAO',
  CONSTRAINT uq_escopo_chamado_versao UNIQUE (id_chamado, versao),
  CONSTRAINT fk_escopo_chamado FOREIGN KEY (id_chamado) REFERENCES chamado(id_chamado),
  CONSTRAINT fk_escopo_reuniao FOREIGN KEY (id_reuniao) REFERENCES reuniao(id_reuniao),
  CONSTRAINT ck_escopo_prazo CHECK (prazo_estimado_dias > 0),
  CONSTRAINT ck_escopo_situacao CHECK (situacao IN ('EM_ELABORACAO','VALIDADO','SUBSTITUIDO','CANCELADO'))
);

CREATE TABLE proposta (
  id_proposta BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_escopo BIGINT UNSIGNED NOT NULL,
  enviada_em DATETIME NULL,
  validade_em DATE NOT NULL,
  condicoes TEXT NOT NULL,
  situacao VARCHAR(15) NOT NULL DEFAULT 'RASCUNHO',
  decidida_em DATETIME NULL,
  CONSTRAINT fk_proposta_escopo FOREIGN KEY (id_escopo) REFERENCES escopo(id_escopo),
  CONSTRAINT ck_proposta_situacao CHECK (situacao IN ('RASCUNHO','ENVIADA','APROVADA','REJEITADA','EXPIRADA')),
  CONSTRAINT ck_proposta_decisao CHECK ((situacao NOT IN ('APROVADA','REJEITADA') OR decidida_em IS NOT NULL) AND (situacao = 'RASCUNHO' OR enviada_em IS NOT NULL))
);

CREATE TABLE contrato_servico (
  id_contrato_servico BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente BIGINT UNSIGNED NOT NULL,
  id_proposta BIGINT UNSIGNED NOT NULL,
  id_responsavel_qore BIGINT UNSIGNED NOT NULL,
  objeto TEXT NOT NULL,
  inicio_vigencia DATE NOT NULL,
  fim_vigencia DATE NULL,
  situacao VARCHAR(15) NOT NULL DEFAULT 'ATIVO',
  responsavel_cliente VARCHAR(150) NOT NULL,
  CONSTRAINT uq_contrato_proposta UNIQUE (id_proposta),
  CONSTRAINT fk_contrato_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_contrato_proposta FOREIGN KEY (id_proposta) REFERENCES proposta(id_proposta),
  CONSTRAINT fk_contrato_responsavel FOREIGN KEY (id_responsavel_qore) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_contrato_vigencia CHECK (fim_vigencia IS NULL OR fim_vigencia >= inicio_vigencia),
  CONSTRAINT ck_contrato_situacao CHECK (situacao IN ('ATIVO','SUSPENSO','ENCERRADO','CANCELADO'))
);

CREATE TABLE projeto (
  id_projeto BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_contrato_servico BIGINT UNSIGNED NOT NULL,
  id_responsavel BIGINT UNSIGNED NOT NULL,
  nome VARCHAR(150) NOT NULL,
  objetivo TEXT NOT NULL,
  inicio_previsto DATE NOT NULL,
  fim_previsto DATE NOT NULL,
  inicio_real DATE NULL,
  fim_real DATE NULL,
  situacao VARCHAR(20) NOT NULL DEFAULT 'PLANEJADO',
  motivo_cancelamento TEXT NULL,
  CONSTRAINT fk_projeto_contrato FOREIGN KEY (id_contrato_servico) REFERENCES contrato_servico(id_contrato_servico),
  CONSTRAINT fk_projeto_responsavel FOREIGN KEY (id_responsavel) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_projeto_datas CHECK (fim_previsto >= inicio_previsto AND (fim_real IS NULL OR inicio_real IS NOT NULL) AND (fim_real IS NULL OR fim_real >= inicio_real)),
  CONSTRAINT ck_projeto_situacao CHECK (situacao IN ('PLANEJADO','EM_ANDAMENTO','EM_HOMOLOGACAO','CONCLUIDO','CANCELADO','SUSPENSO')),
  CONSTRAINT ck_projeto_cancelamento CHECK (situacao <> 'CANCELADO' OR motivo_cancelamento IS NOT NULL)
);

CREATE TABLE alocacao_projeto (
  id_projeto BIGINT UNSIGNED NOT NULL,
  id_funcionario BIGINT UNSIGNED NOT NULL,
  funcao_no_projeto VARCHAR(100) NOT NULL,
  inicio DATE NOT NULL,
  fim DATE NULL,
  dedicacao_percentual DECIMAL(5,2) NULL,
  responsabilidade TEXT NOT NULL,
  PRIMARY KEY (id_projeto, id_funcionario),
  CONSTRAINT fk_alocacao_projeto FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto),
  CONSTRAINT fk_alocacao_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_alocacao_datas CHECK (fim IS NULL OR fim >= inicio),
  CONSTRAINT ck_alocacao_dedicacao CHECK (dedicacao_percentual IS NULL OR dedicacao_percentual > 0 AND dedicacao_percentual <= 100)
);

CREATE TABLE entrega (
  id_entrega BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_projeto BIGINT UNSIGNED NOT NULL,
  id_responsavel BIGINT UNSIGNED NOT NULL,
  versao VARCHAR(30) NOT NULL,
  descricao TEXT NOT NULL,
  entregue_em DATETIME NOT NULL,
  evidencia VARCHAR(255) NULL,
  decisao_cliente VARCHAR(25) NULL,
  decidida_em DATETIME NULL,
  observacao_cliente TEXT NULL,
  CONSTRAINT uq_entrega_projeto_versao UNIQUE (id_projeto, versao),
  CONSTRAINT fk_entrega_projeto FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto),
  CONSTRAINT fk_entrega_responsavel FOREIGN KEY (id_responsavel) REFERENCES funcionario(id_funcionario),
  CONSTRAINT ck_entrega_decisao CHECK (decisao_cliente IS NULL OR decisao_cliente IN ('ACEITA','ACEITA_COM_RESSALVA','REJEITADA')),
  CONSTRAINT ck_entrega_datas CHECK (decidida_em IS NULL OR decidida_em >= entregue_em),
  CONSTRAINT ck_entrega_observacao CHECK (decisao_cliente NOT IN ('ACEITA_COM_RESSALVA','REJEITADA') OR observacao_cliente IS NOT NULL)
);

ALTER TABLE chamado
  ADD CONSTRAINT fk_chamado_projeto FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto),
  ADD CONSTRAINT fk_chamado_entrega FOREIGN KEY (id_entrega) REFERENCES entrega(id_entrega);

CREATE TABLE automacao (
  id_automacao BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_projeto BIGINT UNSIGNED NOT NULL,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(255) NULL,
  situacao VARCHAR(15) NOT NULL DEFAULT 'ATIVA',
  CONSTRAINT uq_automacao_projeto_nome UNIQUE (id_projeto, nome),
  CONSTRAINT fk_automacao_projeto FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto),
  CONSTRAINT ck_automacao_situacao CHECK (situacao IN ('ATIVA','INATIVA','MANUTENCAO','ENCERRADA'))
);

CREATE TABLE execucao (
  id_execucao BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_automacao BIGINT UNSIGNED NOT NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  iniciado_em DATETIME NULL,
  finalizado_em DATETIME NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'CRIADA',
  tipo_consulta VARCHAR(60) NOT NULL,
  total_contratos INT UNSIGNED NOT NULL DEFAULT 0,
  contratos_sucesso INT UNSIGNED NOT NULL DEFAULT 0,
  contratos_erro INT UNSIGNED NOT NULL DEFAULT 0,
  duracao_segundos INT UNSIGNED NULL,
  mensagem_erro TEXT NULL,
  CONSTRAINT fk_execucao_automacao FOREIGN KEY (id_automacao) REFERENCES automacao(id_automacao),
  CONSTRAINT ck_execucao_status CHECK (status IN ('CRIADA','RODANDO','PAUSADA','FINALIZADA','ENCERRADA','ERRO')),
  CONSTRAINT ck_execucao_datas CHECK (finalizado_em IS NULL OR iniciado_em IS NOT NULL AND finalizado_em >= iniciado_em),
  CONSTRAINT ck_execucao_totais CHECK (contratos_sucesso + contratos_erro <= total_contratos)
);

CREATE TABLE contrato_processado (
  id_contrato_processado BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_execucao BIGINT UNSIGNED NOT NULL,
  numero_contrato VARCHAR(30) NOT NULL,
  status VARCHAR(15) NOT NULL DEFAULT 'PENDENTE',
  worker_atual VARCHAR(50) NULL,
  iniciado_em DATETIME NULL,
  finalizado_em DATETIME NULL,
  qtd_parcelas INT UNSIGNED NOT NULL DEFAULT 0,
  qtd_ocorrencias INT UNSIGNED NOT NULL DEFAULT 0,
  mensagem_erro TEXT NULL,
  CONSTRAINT uq_contrato_execucao_numero UNIQUE (id_execucao, numero_contrato),
  CONSTRAINT fk_contrato_processado_execucao FOREIGN KEY (id_execucao) REFERENCES execucao(id_execucao),
  CONSTRAINT ck_contrato_processado_status CHECK (status IN ('PENDENTE','PROCESSANDO','SUCESSO','ERRO')),
  CONSTRAINT ck_contrato_processado_datas CHECK (finalizado_em IS NULL OR iniciado_em IS NOT NULL AND finalizado_em >= iniciado_em)
);

CREATE TABLE evento_execucao (
  id_evento BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_execucao BIGINT UNSIGNED NOT NULL,
  id_contrato_processado BIGINT UNSIGNED NULL,
  worker_label VARCHAR(50) NULL,
  tipo_evento VARCHAR(60) NOT NULL,
  mensagem TEXT NULL,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_evento_execucao FOREIGN KEY (id_execucao) REFERENCES execucao(id_execucao),
  CONSTRAINT fk_evento_contrato FOREIGN KEY (id_contrato_processado) REFERENCES contrato_processado(id_contrato_processado)
);

CREATE TABLE lote_importacao (
  id_lote BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  criado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  finalizado_em DATETIME NULL,
  arquivo_importacao VARCHAR(255) NULL,
  ticket_base VARCHAR(50) NULL,
  qtd_instancias INT UNSIGNED NOT NULL DEFAULT 0,
  total_contratos INT UNSIGNED NOT NULL DEFAULT 0,
  total_linhas INT UNSIGNED NOT NULL DEFAULT 0,
  status VARCHAR(15) NOT NULL DEFAULT 'PROCESSANDO',
  mensagem_erro TEXT NULL,
  CONSTRAINT uq_lote_ticket UNIQUE (ticket_base),
  CONSTRAINT ck_lote_status CHECK (status IN ('PROCESSANDO','CONCLUIDO','ERRO')),
  CONSTRAINT ck_lote_datas CHECK (finalizado_em IS NULL OR finalizado_em >= criado_em)
);

CREATE TABLE instancia_importacao (
  id_instancia BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_lote BIGINT UNSIGNED NOT NULL,
  numero_instancia INT UNSIGNED NOT NULL,
  ticket VARCHAR(50) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'AGUARDANDO',
  status_codigo INT NULL,
  informacao TEXT NULL,
  mensagem_erro TEXT NULL,
  atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  finalizado_em DATETIME NULL,
  CONSTRAINT uq_instancia_lote_numero UNIQUE (id_lote, numero_instancia),
  CONSTRAINT uq_instancia_lote_ticket UNIQUE (id_lote, ticket),
  CONSTRAINT fk_instancia_lote FOREIGN KEY (id_lote) REFERENCES lote_importacao(id_lote),
  CONSTRAINT ck_instancia_numero CHECK (numero_instancia > 0),
  CONSTRAINT ck_instancia_status CHECK (status IN ('AGUARDANDO','PROCESSANDO','CONCLUIDA','ERRO')),
  CONSTRAINT ck_instancia_datas CHECK (finalizado_em IS NULL OR finalizado_em >= atualizado_em)
);

CREATE TABLE participacao_lote (
  id_contrato_processado BIGINT UNSIGNED NOT NULL,
  id_lote BIGINT UNSIGNED NOT NULL,
  status_importacao VARCHAR(15) NOT NULL DEFAULT 'PENDENTE',
  importado_em DATETIME NULL,
  PRIMARY KEY (id_contrato_processado, id_lote),
  CONSTRAINT fk_participacao_contrato FOREIGN KEY (id_contrato_processado) REFERENCES contrato_processado(id_contrato_processado),
  CONSTRAINT fk_participacao_lote FOREIGN KEY (id_lote) REFERENCES lote_importacao(id_lote),
  CONSTRAINT ck_participacao_status CHECK (status_importacao IN ('PENDENTE','RESERVADO','IMPORTADO','ERRO')),
  CONSTRAINT ck_participacao_importado CHECK (status_importacao <> 'IMPORTADO' OR importado_em IS NOT NULL)
);

-- Índices dos caminhos mais usados pelas consultas gerenciais e de auditoria.
CREATE INDEX idx_chamado_cliente_situacao ON chamado(id_cliente, situacao, aberto_em);
CREATE INDEX idx_projeto_situacao_datas ON projeto(situacao, inicio_real, fim_real);
CREATE INDEX idx_entrega_decisao_data ON entrega(decisao_cliente, entregue_em);
CREATE INDEX idx_execucao_status_inicio ON execucao(status, iniciado_em);
CREATE INDEX idx_contrato_processado_status ON contrato_processado(status, finalizado_em);
CREATE INDEX idx_lote_status_criacao ON lote_importacao(status, criado_em);

-- Massa fictícia coerente com diferentes ciclos e estados.
INSERT INTO funcionario (nome, funcao, email_corporativo) VALUES
('Ana Martins','Gerente de Projetos','ana.martins@exemplo.invalid'),
('Bruno Lima','Analista de Sistemas','bruno.lima@exemplo.invalid'),
('Carla Souza','Desenvolvedora','carla.souza@exemplo.invalid'),
('Diego Alves','Analista de Suporte','diego.alves@exemplo.invalid');

INSERT INTO cliente (nome_empresarial, identificacao_empresarial, email_contato, telefone_contato, endereco, situacao) VALUES
('Cliente Alfa Ltda.','FICTICIO-001','contato.alfa@exemplo.invalid','11900000001','São Paulo - SP','ATIVO'),
('Cliente Beta Serviços','FICTICIO-002','contato.beta@exemplo.invalid','11900000002','Santo André - SP','ATIVO'),
('Cliente Gama Comércio','FICTICIO-003','contato.gama@exemplo.invalid','11900000003','São Caetano do Sul - SP','ATIVO'),
('Cliente Delta Indústria','FICTICIO-004','contato.delta@exemplo.invalid','11900000004','São Bernardo do Campo - SP','ATIVO'),
('Cliente Épsilon Saúde','FICTICIO-005','contato.epsilon@exemplo.invalid','11900000005','Campinas - SP','ATIVO'),
('Cliente Zeta Logística','FICTICIO-006','contato.zeta@exemplo.invalid','11900000006','Guarulhos - SP','ATIVO'),
('Cliente Eta Educação','FICTICIO-007','contato.eta@exemplo.invalid','11900000007','Osasco - SP','ATIVO');

INSERT INTO chamado (id_cliente,id_responsavel,solicitante,tipo,prioridade,descricao,aberto_em,prazo_em,situacao,solucao,encerrado_em) VALUES
(1,2,'Solicitante Alfa','SOLICITACAO','ALTA','Automatizar acompanhamento de contratos','2026-08-03 09:00:00','2026-08-10 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-07 16:00:00'),
(1,4,'Operação Alfa','INCIDENTE','CRITICA','Falha em execução agendada','2026-10-21 08:10:00','2026-10-21 12:00:00','RESOLVIDO','Sessão renovada e fila retomada','2026-10-21 10:35:00'),
(2,1,'Solicitante Beta','MELHORIA','MEDIA','Criar painel de indicadores','2026-09-02 10:00:00','2026-09-15 18:00:00','EM_ANALISE',NULL,NULL),
(2,4,'Usuário Beta','DUVIDA','BAIXA','Dúvida sobre relatório mensal','2026-10-28 14:00:00',NULL,'ABERTO',NULL,NULL),
(2,1,'Solicitante Beta 2','SOLICITACAO','MEDIA','Implantar rotina de atendimento fictícia','2026-08-05 09:00:00','2026-08-20 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-08 16:00:00'),
(3,2,'Solicitante Gama','SOLICITACAO','ALTA','Integrar acompanhamento comercial fictício','2026-08-06 09:00:00','2026-08-21 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-09 16:00:00'),
(4,3,'Solicitante Delta','MELHORIA','MEDIA','Automatizar relatório operacional fictício','2026-08-07 09:00:00','2026-08-22 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-10 16:00:00'),
(5,4,'Solicitante Épsilon','SOLICITACAO','ALTA','Criar controle de solicitações fictício','2026-08-08 09:00:00','2026-08-23 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-11 16:00:00'),
(6,1,'Solicitante Zeta','MELHORIA','MEDIA','Revisar fluxo logístico fictício','2026-08-09 09:00:00','2026-08-24 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-12 16:00:00'),
(7,2,'Solicitante Eta','SOLICITACAO','MEDIA','Implantar painel educacional fictício','2026-08-10 09:00:00','2026-08-25 18:00:00','ENCERRADO','Demanda convertida em projeto','2026-08-13 16:00:00');

INSERT INTO reuniao (id_chamado,data_hora,canal_local,participantes_resumo,pauta,decisoes,pendencias) VALUES
(1,'2026-08-04 10:00:00','Sede da organização','Responsável da organização e equipe acadêmica','Fluxo de atendimento e automação','Centralizar rastreabilidade e preservar histórico','Validar indicadores'),
(3,'2026-09-04 15:00:00','Videoconferência autorizada','Cliente Beta e gerente de projetos','Necessidade do painel','Mapear dados disponíveis','Definir metas'),
(5,'2026-08-06 10:00:00','Canal fictício','Cliente Beta e equipe QORE','Rotina de atendimento','Aprovar escopo fictício',NULL),
(6,'2026-08-07 10:00:00','Canal fictício','Cliente Gama e equipe QORE','Acompanhamento comercial','Aprovar escopo fictício',NULL),
(7,'2026-08-08 10:00:00','Canal fictício','Cliente Delta e equipe QORE','Relatório operacional','Aprovar escopo fictício',NULL),
(8,'2026-08-09 10:00:00','Canal fictício','Cliente Épsilon e equipe QORE','Controle de solicitações','Aprovar escopo fictício',NULL),
(9,'2026-08-10 10:00:00','Canal fictício','Cliente Zeta e equipe QORE','Fluxo logístico','Aprovar escopo fictício',NULL),
(10,'2026-08-11 10:00:00','Canal fictício','Cliente Eta e equipe QORE','Painel educacional','Aprovar escopo fictício',NULL);

INSERT INTO escopo (id_chamado,id_reuniao,versao,requisitos,entregas_previstas,limites,premissas,prazo_estimado_dias,situacao) VALUES
(1,1,'1.0','Cadastro, execução, auditoria e importação','Automação e acompanhamento operacional','Sem dados bancários reais','Ambiente autorizado disponível',60,'VALIDADO'),
(3,2,'0.1','Indicadores de projetos e chamados','Protótipo de painel','Sem integração externa','Dados fictícios para homologação',30,'EM_ELABORACAO'),
(5,3,'1.0','Rotina de atendimento','Solução fictícia Beta','Sem dados reais','Ambiente acadêmico',45,'VALIDADO'),
(6,4,'1.0','Acompanhamento comercial','Solução fictícia Gama','Sem dados reais','Ambiente acadêmico',45,'VALIDADO'),
(7,5,'1.0','Relatório operacional','Solução fictícia Delta','Sem dados reais','Ambiente acadêmico',45,'VALIDADO'),
(8,6,'1.0','Controle de solicitações','Solução fictícia Épsilon','Sem dados reais','Ambiente acadêmico',45,'VALIDADO'),
(9,7,'1.0','Fluxo logístico','Solução fictícia Zeta','Sem dados reais','Ambiente acadêmico',45,'VALIDADO'),
(10,8,'1.0','Painel educacional','Solução fictícia Eta','Sem dados reais','Ambiente acadêmico',45,'VALIDADO');

INSERT INTO proposta (id_escopo,enviada_em,validade_em,condicoes,situacao,decidida_em) VALUES
(1,'2026-08-05 09:00:00','2026-08-20','Condições acadêmicas fictícias','APROVADA','2026-08-06 11:00:00'),
(2,'2026-09-08 09:00:00','2026-09-20','Condições acadêmicas fictícias','EXPIRADA',NULL),
(2,'2026-10-01 09:00:00','2026-10-15','Condições acadêmicas fictícias','REJEITADA','2026-10-10 16:00:00'),
(3,'2026-08-07 09:00:00','2026-08-22','Condições acadêmicas fictícias','APROVADA','2026-08-08 11:00:00'),
(4,'2026-08-08 09:00:00','2026-08-23','Condições acadêmicas fictícias','APROVADA','2026-08-09 11:00:00'),
(5,'2026-08-09 09:00:00','2026-08-24','Condições acadêmicas fictícias','APROVADA','2026-08-10 11:00:00'),
(6,'2026-08-10 09:00:00','2026-08-25','Condições acadêmicas fictícias','APROVADA','2026-08-11 11:00:00'),
(7,'2026-08-11 09:00:00','2026-08-26','Condições acadêmicas fictícias','APROVADA','2026-08-12 11:00:00'),
(8,'2026-08-12 09:00:00','2026-08-27','Condições acadêmicas fictícias','APROVADA','2026-08-13 11:00:00');

INSERT INTO contrato_servico (id_cliente,id_proposta,id_responsavel_qore,objeto,inicio_vigencia,fim_vigencia,situacao,responsavel_cliente) VALUES
(1,1,1,'Desenvolvimento de automação fictícia','2026-08-10','2027-08-09','ATIVO','Responsável Alfa'),
(2,4,2,'Serviço fictício Beta','2026-08-12','2027-08-11','ATIVO','Responsável Beta'),
(3,5,3,'Serviço fictício Gama','2026-08-13','2027-08-12','ATIVO','Responsável Gama'),
(4,6,4,'Serviço fictício Delta','2026-08-14','2027-08-13','ATIVO','Responsável Delta'),
(5,7,1,'Serviço fictício Épsilon','2026-08-15','2027-08-14','ATIVO','Responsável Épsilon'),
(6,8,2,'Serviço fictício Zeta','2026-08-16','2027-08-15','ATIVO','Responsável Zeta'),
(7,9,3,'Serviço fictício Eta','2026-08-17','2027-08-16','ATIVO','Responsável Eta');

INSERT INTO projeto (id_contrato_servico,id_responsavel,nome,objetivo,inicio_previsto,fim_previsto,inicio_real,fim_real,situacao) VALUES
(1,1,'Automação Alfa','Automatizar consultas e manter rastreabilidade','2026-08-10','2026-10-30','2026-08-10',NULL,'EM_HOMOLOGACAO');

-- Completa uma massa representativa de 21 projetos ativos, distribuídos entre sete contratos.
INSERT INTO projeto (id_contrato_servico,id_responsavel,nome,objetivo,inicio_previsto,fim_previsto,inicio_real,fim_real,situacao)
SELECT 1 + MOD(n,7),
       1 + MOD(n,4),
       CONCAT('Projeto demonstrativo ', LPAD(n,2,'0')),
       'Exercitar volume, estados e consultas gerenciais com dados fictícios',
       DATE_ADD('2026-01-05', INTERVAL n DAY),
       DATE_ADD('2026-12-01', INTERVAL n DAY),
       DATE_ADD('2026-01-05', INTERVAL n DAY),
       NULL,
       CASE WHEN MOD(n,4)=0 THEN 'EM_HOMOLOGACAO'
            ELSE 'EM_ANDAMENTO' END
FROM (
    SELECT unidade.n + dezena.n * 10 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) unidade
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2) dezena
) numeros
WHERE n BETWEEN 1 AND 20;

-- Completa 101 chamados no mês de referência, distribuídos entre os sete clientes.
INSERT INTO chamado (id_cliente,id_responsavel,solicitante,tipo,prioridade,descricao,aberto_em,prazo_em,situacao,solucao,encerrado_em)
SELECT 1 + MOD(n,7),
       1 + MOD(n,4),
       CONCAT('Solicitante fictício ', LPAD(n,3,'0')),
       ELT(1 + MOD(n,4),'SOLICITACAO','INCIDENTE','MELHORIA','DUVIDA'),
       ELT(1 + MOD(n,4),'BAIXA','MEDIA','ALTA','CRITICA'),
       CONCAT('Chamado fictício de volume ', LPAD(n,3,'0')),
       DATE_ADD('2026-10-01 08:00:00', INTERVAL n HOUR),
       DATE_ADD('2026-10-03 18:00:00', INTERVAL n HOUR),
       CASE WHEN MOD(n,3)=0 THEN 'ENCERRADO'
            WHEN MOD(n,3)=1 THEN 'EM_ATENDIMENTO'
            ELSE 'ABERTO' END,
       CASE WHEN MOD(n,3)=0 THEN 'Atendimento fictício concluído' ELSE NULL END,
       CASE WHEN MOD(n,3)=0 THEN DATE_ADD('2026-10-02 12:00:00', INTERVAL n HOUR) ELSE NULL END
FROM (
    SELECT unidade.n + dezena.n * 10 + centena.n * 100 AS n
    FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
          UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) unidade
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
                UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) dezena
    CROSS JOIN (SELECT 0 n UNION ALL SELECT 1) centena
) numeros
WHERE n BETWEEN 11 AND 101;

INSERT INTO alocacao_projeto (id_projeto,id_funcionario,funcao_no_projeto,inicio,fim,dedicacao_percentual,responsabilidade) VALUES
(1,1,'Gerente de projeto','2026-08-10',NULL,25.00,'Coordenar entregas e aceite'),
(1,2,'Analista','2026-08-10',NULL,50.00,'Especificar regras e validar dados'),
(1,3,'Desenvolvedora','2026-08-12',NULL,80.00,'Implementar automação');

-- Todo projeto ativo possui ao menos uma pessoa alocada, conforme RN23 e RN24.
INSERT INTO alocacao_projeto (id_projeto,id_funcionario,funcao_no_projeto,inicio,fim,dedicacao_percentual,responsabilidade)
SELECT p.id_projeto,
       1 + MOD(p.id_projeto,4),
       'Responsável técnico',
       p.inicio_real,
       NULL,
       50.00,
       'Conduzir o projeto fictício e registrar seu acompanhamento'
FROM projeto p
WHERE p.id_projeto > 1;

INSERT INTO entrega (id_projeto,id_responsavel,versao,descricao,entregue_em,evidencia,decisao_cliente,decidida_em,observacao_cliente) VALUES
(1,3,'1.0.0','Primeira versão para homologação','2026-10-01 15:00:00','evidencias/entrega-1.txt','ACEITA_COM_RESSALVA','2026-10-03 11:00:00','Ajustar relatório de erros'),
(1,3,'1.1.0','Versão com ajuste solicitado','2026-10-20 15:00:00','evidencias/entrega-2.txt','ACEITA','2026-10-21 14:00:00',NULL);

UPDATE chamado SET id_projeto=1, id_entrega=2 WHERE id_chamado=2;

INSERT INTO automacao (id_projeto,nome,descricao,situacao) VALUES
(1,'Automação Alfa Contratos','Consulta e classificação de contratos fictícios','ATIVA');

INSERT INTO execucao (id_automacao,criado_em,iniciado_em,finalizado_em,status,tipo_consulta,total_contratos,contratos_sucesso,contratos_erro,duracao_segundos,mensagem_erro) VALUES
(1,'2026-10-20 22:00:00','2026-10-20 22:01:00','2026-10-20 22:21:00','FINALIZADA','FILA_DIARIA',3,2,1,1200,NULL),
(1,'2026-10-21 07:00:00','2026-10-21 07:01:00','2026-10-21 07:08:00','ERRO','CADASTROS_HOJE',2,1,1,420,'Falha sanitizada de sessão'),
(1,'2026-10-22 22:00:00','2026-10-22 22:01:00','2026-10-22 22:16:00','FINALIZADA','FILA_DIARIA',2,2,0,900,NULL);

INSERT INTO contrato_processado (id_execucao,numero_contrato,status,worker_atual,iniciado_em,finalizado_em,qtd_parcelas,qtd_ocorrencias,mensagem_erro) VALUES
(1,'CT-FICT-001','SUCESSO','worker-01','2026-10-20 22:02:00','2026-10-20 22:05:00',12,2,NULL),
(1,'CT-FICT-002','SUCESSO','worker-02','2026-10-20 22:02:00','2026-10-20 22:06:00',8,1,NULL),
(1,'CT-FICT-003','ERRO','worker-03','2026-10-20 22:03:00','2026-10-20 22:07:00',0,0,'Contrato indisponível'),
(2,'CT-FICT-004','SUCESSO','worker-01','2026-10-21 07:02:00','2026-10-21 07:04:00',10,3,NULL),
(2,'CT-FICT-005','ERRO','worker-02','2026-10-21 07:02:00','2026-10-21 07:06:00',0,0,'Sessão expirada'),
(3,'CT-FICT-006','SUCESSO','worker-01','2026-10-22 22:02:00','2026-10-22 22:05:00',6,1,NULL),
(3,'CT-FICT-007','SUCESSO','worker-02','2026-10-22 22:02:00','2026-10-22 22:06:00',14,2,NULL);

INSERT INTO evento_execucao (id_execucao,id_contrato_processado,worker_label,tipo_evento,mensagem,criado_em) VALUES
(1,NULL,NULL,'EXECUCAO_INICIADA','Fila fictícia iniciada','2026-10-20 22:01:00'),
(1,3,'worker-03','CONTRATO_ERRO','Contrato indisponível','2026-10-20 22:07:00'),
(2,5,'worker-02','SESSAO_EXPIRADA','Sessão precisa ser renovada','2026-10-21 07:06:00'),
(3,NULL,NULL,'EXECUCAO_FINALIZADA','Fila concluída sem erro','2026-10-22 22:16:00');

INSERT INTO lote_importacao (criado_em,atualizado_em,finalizado_em,arquivo_importacao,ticket_base,qtd_instancias,total_contratos,total_linhas,status,mensagem_erro) VALUES
('2026-10-20 23:00:00','2026-10-20 23:20:00','2026-10-20 23:20:00','lote_ficticio_001.zip','TICKET-FICT-001',2,2,5,'CONCLUIDO',NULL),
('2026-10-21 08:00:00','2026-10-21 08:15:00',NULL,'lote_ficticio_002.zip','TICKET-FICT-002',2,2,3,'PROCESSANDO',NULL),
('2026-10-22 23:00:00','2026-10-22 23:12:00','2026-10-22 23:12:00','lote_ficticio_003.zip','TICKET-FICT-003',1,2,4,'ERRO','Uma instância retornou erro');

INSERT INTO instancia_importacao (id_lote,numero_instancia,ticket,status,status_codigo,informacao,mensagem_erro,atualizado_em,finalizado_em) VALUES
(1,1,'TICKET-FICT-001-01','CONCLUIDA',200,'Importação concluída',NULL,'2026-10-20 23:20:00','2026-10-20 23:20:00'),
(1,2,'TICKET-FICT-001-02','CONCLUIDA',200,'Importação concluída',NULL,'2026-10-20 23:19:00','2026-10-20 23:19:00'),
(2,1,'TICKET-FICT-002-01','PROCESSANDO',102,'Em processamento',NULL,'2026-10-21 08:15:00',NULL),
(2,2,'TICKET-FICT-002-02','AGUARDANDO',100,'Aguardando processamento',NULL,'2026-10-21 08:15:00',NULL),
(3,1,'TICKET-FICT-003-01','ERRO',500,NULL,'Erro fictício de validação','2026-10-22 23:12:00','2026-10-22 23:12:00');

INSERT INTO participacao_lote (id_contrato_processado,id_lote,status_importacao,importado_em) VALUES
(1,1,'IMPORTADO','2026-10-20 23:20:00'),
(2,1,'IMPORTADO','2026-10-20 23:20:00'),
(4,2,'RESERVADO',NULL),
(5,2,'ERRO',NULL),
(6,3,'ERRO',NULL),
(7,3,'ERRO',NULL);

-- Exemplo obrigatório de UPDATE: altera um chamado fictício em atendimento.
UPDATE chamado
SET situacao = 'EM_ATENDIMENTO', id_responsavel = 4
WHERE id_chamado = 4;

-- Exemplo obrigatório de DELETE: registro temporário fictício, sem dependências.
INSERT INTO cliente (nome_empresarial, identificacao_empresarial, situacao)
VALUES ('Cliente temporário para demonstração','FICTICIO-TEMP','INATIVO');
DELETE FROM cliente WHERE identificacao_empresarial = 'FICTICIO-TEMP';

-- G01 - Quais chamados permanecem abertos por cliente e prioridade?
-- Atende P01 e P04. KPI: chamados abertos por situação no período.
SELECT c.nome_empresarial, ch.prioridade, ch.situacao, COUNT(*) AS total_chamados
FROM cliente c JOIN chamado ch ON ch.id_cliente = c.id_cliente
WHERE ch.situacao NOT IN ('ENCERRADO','CANCELADO')
GROUP BY c.nome_empresarial, ch.prioridade, ch.situacao
ORDER BY FIELD(ch.prioridade,'CRITICA','ALTA','MEDIA','BAIXA'), total_chamados DESC;

-- G02 - Qual é o tempo médio de resolução dos chamados encerrados, em horas?
-- Atende P04. KPI: média de TIMESTAMPDIFF entre abertura e encerramento por mês.
SELECT DATE_FORMAT(aberto_em,'%Y-%m') AS periodo,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE,aberto_em,encerrado_em))/60,2) AS horas_medias
FROM chamado WHERE encerrado_em IS NOT NULL GROUP BY DATE_FORMAT(aberto_em,'%Y-%m');

-- G03 - Quais propostas foram aprovadas, rejeitadas ou expiraram?
-- Atende P02. KPI: taxa de aprovação por período.
SELECT DATE_FORMAT(COALESCE(decidida_em,enviada_em),'%Y-%m') AS periodo, situacao, COUNT(*) AS total
FROM proposta WHERE situacao IN ('APROVADA','REJEITADA','EXPIRADA')
GROUP BY periodo, situacao ORDER BY periodo, situacao;

-- G04 - Quais projetos estão ativos e quem responde por eles?
-- Atende P03. KPI: projetos em andamento por responsável.
SELECT p.nome AS projeto, p.situacao, f.nome AS responsavel, p.fim_previsto
FROM projeto p JOIN funcionario f ON f.id_funcionario = p.id_responsavel
WHERE p.situacao IN ('PLANEJADO','EM_ANDAMENTO','EM_HOMOLOGACAO','SUSPENSO');

-- G05 - Qual é a dedicação da equipe em cada projeto?
-- Atende P03. KPI: soma da dedicação percentual por projeto.
SELECT p.nome AS projeto, COUNT(*) AS pessoas_alocadas,
       ROUND(SUM(COALESCE(a.dedicacao_percentual,0)),2) AS dedicacao_percentual_total
FROM projeto p JOIN alocacao_projeto a ON a.id_projeto=p.id_projeto
GROUP BY p.id_projeto,p.nome;

-- G06 - Qual é a taxa de aceite das entregas por projeto?
-- Atende P05. KPI: entregas aceitas dividido por entregas decididas.
SELECT p.nome AS projeto, COUNT(*) AS entregas_decididas,
       ROUND(100*SUM(e.decisao_cliente IN ('ACEITA','ACEITA_COM_RESSALVA'))/COUNT(*),2) AS taxa_aceite_percentual
FROM projeto p JOIN entrega e ON e.id_projeto=p.id_projeto
WHERE e.decisao_cliente IS NOT NULL GROUP BY p.id_projeto,p.nome;

-- G07 - Qual é a taxa de sucesso das execuções da automação?
-- Atende P06 e P07. KPI: contratos com sucesso dividido pelo total processado.
SELECT a.nome AS automacao, COUNT(*) AS execucoes,
       SUM(ex.total_contratos) AS contratos,
       ROUND(100*SUM(ex.contratos_sucesso)/NULLIF(SUM(ex.total_contratos),0),2) AS taxa_sucesso_percentual
FROM automacao a JOIN execucao ex ON ex.id_automacao=a.id_automacao
GROUP BY a.id_automacao,a.nome;

-- G08 - Quais erros de processamento ocorreram por contrato e execução?
-- Atende P08. KPI: contratos com erro por tipo de consulta.
SELECT ex.tipo_consulta, cp.numero_contrato, cp.worker_atual, cp.mensagem_erro, cp.finalizado_em
FROM execucao ex JOIN contrato_processado cp ON cp.id_execucao=ex.id_execucao
WHERE cp.status='ERRO' ORDER BY cp.finalizado_em DESC;

-- G09 - Quais lotes e instâncias ainda não terminaram?
-- Atende P09. KPI: lotes pendentes e idade em horas.
SELECT l.id_lote,l.ticket_base,l.status,COUNT(i.id_instancia) AS instancias,
       SUM(i.status IN ('AGUARDANDO','PROCESSANDO')) AS instancias_pendentes,
       TIMESTAMPDIFF(HOUR,l.criado_em,NOW()) AS idade_horas
FROM lote_importacao l LEFT JOIN instancia_importacao i ON i.id_lote=l.id_lote
WHERE l.status <> 'CONCLUIDO' GROUP BY l.id_lote,l.ticket_base,l.status,l.criado_em;

-- G10 - Qual é o ciclo completo entre cliente, chamado, contrato, projeto e entrega?
-- Atende P01, P02, P03, P05 e P06. KPI: rastreabilidade de ponta a ponta.
SELECT c.nome_empresarial,ch.id_chamado,cs.id_contrato_servico,p.nome AS projeto,
       e.versao AS entrega,e.decisao_cliente,a.nome AS automacao
FROM cliente c
JOIN chamado ch ON ch.id_cliente=c.id_cliente
LEFT JOIN projeto p ON p.id_projeto=ch.id_projeto
LEFT JOIN contrato_servico cs ON cs.id_contrato_servico=p.id_contrato_servico
LEFT JOIN entrega e ON e.id_projeto=p.id_projeto
LEFT JOIN automacao a ON a.id_projeto=p.id_projeto
ORDER BY c.nome_empresarial,ch.id_chamado,e.entregue_em;

-- A01 - Existem chamados encerrados sem solução ou sem data de encerramento?
-- Audita RN17 e RN28 e atende P04.
SELECT * FROM chamado WHERE situacao='ENCERRADO' AND (solucao IS NULL OR encerrado_em IS NULL);

-- A02 - Existem propostas aprovadas sem decisão registrada?
-- Audita RN20 e atende P02.
SELECT * FROM proposta WHERE situacao='APROVADA' AND decidida_em IS NULL;

-- A03 - Existe contrato ligado a proposta que não está aprovada?
-- Audita RN21 e atende P02.
SELECT cs.id_contrato_servico,p.situacao FROM contrato_servico cs
JOIN proposta p ON p.id_proposta=cs.id_proposta WHERE p.situacao <> 'APROVADA';

-- A04 - Existem projetos concluídos sem data real de término?
-- Audita RN26 e RN27 e atende P03.
SELECT * FROM projeto WHERE situacao='CONCLUIDO' AND fim_real IS NULL;

-- A05 - Existem projetos sem funcionário alocado?
-- Audita RN23 e RN24 e atende P03.
SELECT p.id_projeto,p.nome FROM projeto p LEFT JOIN alocacao_projeto a ON a.id_projeto=p.id_projeto
WHERE a.id_projeto IS NULL;

-- A06 - Existem entregas com ressalva ou rejeição sem observação?
-- Audita RN25 e RN26 e atende P05.
SELECT * FROM entrega WHERE decisao_cliente IN ('ACEITA_COM_RESSALVA','REJEITADA') AND observacao_cliente IS NULL;

-- A07 - Os totais consolidados das execuções divergem dos contratos processados?
-- Audita RN01, RN05 e RN16 e atende P07/P08.
SELECT ex.id_execucao,ex.total_contratos,COUNT(cp.id_contrato_processado) AS registros,
       ex.contratos_sucesso,SUM(cp.status='SUCESSO') AS sucessos,
       ex.contratos_erro,SUM(cp.status='ERRO') AS erros
FROM execucao ex LEFT JOIN contrato_processado cp ON cp.id_execucao=ex.id_execucao
GROUP BY ex.id_execucao,ex.total_contratos,ex.contratos_sucesso,ex.contratos_erro
HAVING total_contratos<>registros OR contratos_sucesso<>sucessos OR contratos_erro<>erros;

-- A08 - Existem eventos ligados a contrato de outra execução?
-- Audita RN01 e RN13 e atende P08.
SELECT ev.id_evento,ev.id_execucao,cp.id_execucao AS execucao_contrato
FROM evento_execucao ev JOIN contrato_processado cp ON cp.id_contrato_processado=ev.id_contrato_processado
WHERE ev.id_execucao<>cp.id_execucao;

-- A09 - Existem lotes concluídos com instâncias não concluídas?
-- Audita RN15 e atende P09.
SELECT l.id_lote,l.status,i.id_instancia,i.status AS status_instancia
FROM lote_importacao l JOIN instancia_importacao i ON i.id_lote=l.id_lote
WHERE l.status='CONCLUIDO' AND i.status<>'CONCLUIDA';

-- A10 - Existem participações marcadas como importadas sem confirmação temporal?
-- Audita RN14 e RN15 e atende P09.
SELECT * FROM participacao_lote WHERE status_importacao='IMPORTADO' AND importado_em IS NULL;
