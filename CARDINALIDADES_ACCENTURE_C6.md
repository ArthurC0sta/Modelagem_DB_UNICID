# Cardinalidades — Ciclo de Serviços da QORE

## Status e escopo

Este documento descreve o **modelo conceitual proposto para a revisão da Entrega 1**. O escopo cobre o ciclo desde o cadastro do cliente até a finalização do projeto e conecta a automação Accenture C6 como subsistema técnico. As cardinalidades usam a notação `(mínimo, máximo)` nos dois lados.

## Núcleo organizacional

| Origem | Relacionamento | Destino | Origem | Destino | Leitura |
|---|---|---|---:|---:|---|
| `CLIENTE` | abre | `CHAMADO` | `(0,n)` | `(1,1)` | Um cliente pode não ter chamados; todo chamado pertence a um cliente. |
| `CHAMADO` | possui | `REUNIAO` | `(0,n)` | `(1,1)` | Um chamado pode exigir várias reuniões; cada reunião pertence a um chamado. |
| `REUNIAO` | define | `ESCOPO` | `(0,n)` | `(1,1)` | Uma reunião pode não gerar escopo ou contribuir para versões; cada escopo deriva de uma reunião. |
| `ESCOPO` | fundamenta | `PROPOSTA` | `(0,n)` | `(1,1)` | Um escopo pode fundamentar propostas revisadas; toda proposta se baseia em um escopo. |
| `PROPOSTA` | gera | `CONTRATO_SERVICO` | `(0,1)` | `(1,1)` | Uma proposta pode não ser aprovada; todo contrato deriva de uma proposta aprovada. |
| `CONTRATO_SERVICO` | abre | `PROJETO` | `(0,n)` | `(1,1)` | Um contrato pode existir antes da abertura e sustentar mais de um projeto; todo projeto pertence a um contrato. |
| `CHAMADO` | refere-se a | `PROJETO` | `(0,1)` | `(0,n)` | Uma solicitação inicial pode preceder o projeto; um chamado de suporte pode apontar para um projeto, que pode possuir vários chamados. |
| `CHAMADO` | relata | `ENTREGA` | `(0,1)` | `(0,n)` | Um chamado pode tratar de uma entrega específica; uma entrega pode originar vários atendimentos. |
| `FUNCIONARIO` | participa por | `ALOCACAO_PROJETO` | `(0,n)` | `(1,1)` | Um funcionário pode participar de vários projetos; cada alocação identifica um funcionário. |
| `PROJETO` | recebe | `ALOCACAO_PROJETO` | `(1,n)` | `(1,1)` | Todo projeto possui ao menos um responsável; cada alocação pertence a um projeto. |
| `PROJETO` | produz | `ENTREGA` | `(0,n)` | `(1,1)` | Um projeto pode ainda não ter entregas; toda entrega pertence a um projeto. |
| `PROJETO` | possui | `AUTOMACAO` | `(0,n)` | `(1,1)` | Nem todo projeto produz automação; toda automação modelada pertence a um projeto. |

## Subsistema técnico Accenture C6

| Origem | Relacionamento | Destino | Origem | Destino | Leitura |
|---|---|---|---:|---:|---|
| `AUTOMACAO` | gera | `EXECUCAO` | `(0,n)` | `(1,1)` | Uma automação pode ainda não ter execuções; toda execução pertence a uma automação. |
| `EXECUCAO` | processa | `CONTRATO_PROCESSADO` | `(0,n)` | `(1,1)` | Uma execução vazia é válida; todo contrato processado pertence a uma execução. |
| `EXECUCAO` | registra | `EVENTO_EXECUCAO` | `(0,n)` | `(1,1)` | Uma execução pode existir antes do primeiro evento; todo evento pertence a uma execução. |
| `CONTRATO_PROCESSADO` | contextualiza | `EVENTO_EXECUCAO` | `(0,n)` | `(0,1)` | Um contrato pode possuir eventos; eventos gerais não precisam apontar para contrato. |
| `CONTRATO_PROCESSADO` | participa por | `PARTICIPACAO_LOTE` | `(0,n)` | `(1,1)` | Um contrato pode não ser importado ou participar de diferentes lotes. |
| `LOTE_IMPORTACAO` | contém | `PARTICIPACAO_LOTE` | `(1,n)` | `(1,1)` | Um lote efetivo contém ao menos um contrato processado. |
| `LOTE_IMPORTACAO` | acompanha | `INSTANCIA_IMPORTACAO` | `(0,n)` | `(1,1)` | Um lote pode existir antes do retorno; toda instância pertence a um lote. |

## Entidades associativas

### ALOCACAO_PROJETO

Resolve a relação N:N entre `FUNCIONARIO` e `PROJETO` e possui atributos próprios:

- função no projeto;
- início e fim da participação;
- dedicação;
- responsabilidade.

### PARTICIPACAO_LOTE

Resolve a relação N:N entre `CONTRATO_PROCESSADO` e `LOTE_IMPORTACAO` e possui:

- situação da importação;
- momento da confirmação.

## Restrições conceituais

- todo projeto pertence a um contrato de serviço derivado de proposta aprovada;
- chamados de suporte podem se vincular diretamente ao projeto e, quando aplicável, à entrega relacionada;
- todo projeto possui ao menos uma alocação responsável;
- projeto concluído possui entrega com decisão do cliente;
- projeto cancelado preserva data, responsável e motivo;
- contrato processado é único dentro da execução pelo número consultado;
- a mesma combinação de contrato processado e lote participa uma única vez;
- número da instância e ticket são únicos dentro do lote relacionado;
- todo evento pertence a uma execução e pode opcionalmente contextualizar um contrato processado;
- após envio aceito pelo CSLOG, o lote deve possuir ao menos uma instância de acompanhamento;
- o DER conceitual não apresenta chaves estrangeiras.
