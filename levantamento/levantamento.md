# Levantamento de requisitos — QORE Tecnologia

## Identificação

| Campo | Registro |
|---|---|
| Organização | QORE Tecnologia |
| Natureza | Empresa privada brasileira de tecnologia da informação |
| Endereço observado/informado | R. Niterói, 62 — São Caetano do Sul, SP |
| Responsável consultado | Leonardo Queiroz — CEO |
| Contato para confirmação | Telefone institucional (11) 4081-5292 |
| Participantes | Leonardo Queiroz, Renan Medeiros e Arthur Costa |
| Evidência | [EQUIPE_QORE_EMPRESA_CONSULTADA.png](../EQUIPE_QORE_EMPRESA_CONSULTADA.png) |
| Data comprovada nos arquivos | 17/09/2026 — registro da reunião remota |
| Evidência presencial exigida | Não comprovada pelos arquivos atuais; anexar fotografia original e registrar a data real da visita antes do envio ao professor |

O grupo declarou a atividade presencial como concluída. Entretanto, a imagem disponível registra uma reunião remota. Para não transformar uma declaração em evidência, este levantamento distingue o que está comprovado do que ainda precisa ser anexado pelo grupo.

## Objetivo do levantamento

Compreender como a QORE registra e acompanha um serviço desde o primeiro contato do cliente até o encerramento do projeto e o suporte posterior. O levantamento também analisou a automação Accenture C6 como exemplo técnico de projeto que produz execuções, processa contratos e envia lotes a um sistema externo.

## Perguntas tratadas na entrevista

- Como uma necessidade de cliente chega à QORE?
- Quem analisa o chamado e registra decisões?
- Como reunião, escopo e proposta se transformam em contrato e projeto?
- Como a equipe e as responsabilidades são definidas?
- Como a organização registra entrega, aceite, ressalva e rejeição?
- Como o suporte posterior preserva o vínculo com projeto e entrega?
- Quais estados, falhas e retomadas precisam ser registrados nas automações?
- Como um lote enviado ao CSLOG é acompanhado até o estado terminal?
- Quais dados exigem restrição de acesso e não podem ser publicados?

## Informações confirmadas na entrevista

- A QORE possui aproximadamente 50 funcionários.
- A organização mantém aproximadamente sete clientes ativos, mais de 20 projetos ativos e recebe mais de 100 chamados mensais.
- O ciclo do serviço envolve chamado, análise, reunião, escopo, proposta, contrato, projeto, alocação, entrega, aceite e suporte.
- A solicitação do caso Accenture C6 partiu de Letícia Ferrari, da DNR Teleserviços.
- A QORE recebeu a demanda e Arthur Costa ficou responsável pelo desenvolvimento da automação.
- Um projeto pode gerar uma automação com várias execuções.
- A integração com o CSLOG pode devolver vários tickets para um mesmo lote.
- Dados reais de clientes, valores comerciais, números de contratos, credenciais e respostas brutas não devem integrar o repositório acadêmico.

## Achados do processo informados pelo grupo

Os achados abaixo sintetizam o fluxo informado e analisado. Eles somente devem ser apresentados como observação presencial depois de confrontados com a visita e sua fotografia:

1. As informações atravessam áreas e etapas diferentes; sem uma chave comum, torna-se difícil relacionar a necessidade inicial ao resultado entregue.
2. Chamados podem existir antes do projeto, durante o desenvolvimento ou depois da entrega.
3. Escopo e proposta precisam de versão e situação próprias, pois podem ser revisados ou encerrados antes da contratação.
4. A participação de um funcionário pertence ao contexto do projeto e possui função, período, dedicação e responsabilidade.
5. O aceite pertence a uma entrega específica; uma entrega pode receber aceite, ressalva ou rejeição.
6. A automação mantém estados intermediários, eventos e erros que não podem ser reduzidos ao estado final da execução.
7. O lote somente pode ser tratado como concluído quando todas as instâncias válidas atingirem estado terminal de sucesso.

## Problemas identificados

| Código | Problema de gestão da informação |
|---|---|
| P01 | Preservar o vínculo entre cliente, chamado e projeto durante todo o ciclo. |
| P02 | Rastrear decisões desde a reunião até a proposta e a contratação. |
| P03 | Acompanhar situação, responsáveis, equipe, entrega e finalização dos projetos. |
| P04 | Controlar cliente, tipo, prioridade, prazo, responsável e solução dos chamados. |
| P05 | Registrar entrega e aceite para tornar a finalização auditável. |
| P06 | Ligar automações e execuções ao projeto que lhes deu origem. |
| P07 | Evitar processamento duplicado de contratos. |
| P08 | Preservar progresso e falhas para permitir retomada. |
| P09 | Acompanhar todas as instâncias de um lote antes da confirmação. |
| P10 | Restringir acesso a dados pessoais, comerciais e operacionais. |

## Mudanças em relação à Entrega 1 inicial

O recorte anterior representava principalmente a automação. A revisão passou a cobrir a organização como um todo, incluindo cliente, chamado, reunião, escopo, proposta, contrato de serviço, projeto, funcionário, alocação e entrega. O contrato comercial foi separado do contrato técnico processado. O novo DER possui 17 entidades e 19 relacionamentos.

## Volumes usados para dimensionar a massa

O modelo considera os volumes declarados de aproximadamente 50 funcionários, sete clientes ativos, mais de 20 projetos ativos e mais de 100 chamados por mês. A massa SQL representa sete clientes ativos, 21 projetos ativos e 101 chamados fictícios. Os projetos estão distribuídos entre os contratos dos sete clientes e todos possuem ao menos uma alocação, além dos estados variados de propostas, entregas, execuções e importações.

## Limites e privacidade

O trabalho não publica dados pessoais reais, condições comerciais, números reais de contratos, cookies, tokens ou credenciais. Os dados do script são fictícios. A fotografia permanece apenas como evidência acadêmica e seu uso deve respeitar a autorização dada ao grupo.

## Validação com a organização

O grupo deve fazer a conferência final dos seguintes pontos antes do envio:

- transcrever a data exata da visita;
- confirmar que o telefone institucional é suficiente para o contato do professor ou substituir pelo telefone autorizado do responsável;
- confirmar a autorização de uso acadêmico da fotografia;
- verificar se os achados descritos como observação correspondem ao que o grupo presenciou.
