# Cardinalidades — Automação Accenture C6

## Escopo aprovado

O modelo acadêmico possui sete entidades:

1. `AUTOMACAO`
2. `EXECUCAO`
3. `CONTRATO`
4. `EVENTO_EXECUCAO`
5. `LOTE_IMPORTACAO`
6. `INSTANCIA_IMPORTACAO`
7. `CONTRATO_LOTE_IMPORTACAO`

`PROCESSAMENTO_CONTRATO`, `WORKER` e `MOVIMENTO_CSLOG` não são entidades do modelo final. A quantidade de workers é representada como métrica derivada em `EXECUCAO`. A rastreabilidade necessária após a retirada de `MOVIMENTO_CSLOG` é preservada por `CONTRATO_LOTE_IMPORTACAO`.

## Relacionamentos e participações

| Origem | Cardinalidade | Destino | Regra de integridade |
|---|---:|---|---|
| `AUTOMACAO` | 1 : 0..N | `EXECUCAO` | Uma execução pertence obrigatoriamente a uma automação; uma automação pode ainda não ter execuções. |
| `EXECUCAO` | 1 : 0..N | `CONTRATO` | Um contrato processado pertence a uma única execução; uma execução pode terminar sem contratos retornados. |
| `EXECUCAO` | 1 : 0..N | `EVENTO_EXECUCAO` | Todo evento pertence a uma execução; a execução pode existir antes do primeiro evento. |
| `CONTRATO` | 0..1 : 0..N | `EVENTO_EXECUCAO` | Um evento refere-se a zero ou um contrato; um contrato pode possuir vários eventos. Eventos gerais mantêm a FK de contrato nula. |
| `CONTRATO` | 1 : 0..N | `CONTRATO_LOTE_IMPORTACAO` | Um contrato pode não ser importado ou pode participar de diferentes lotes ao longo do processo. |
| `LOTE_IMPORTACAO` | 1 : 1..N | `CONTRATO_LOTE_IMPORTACAO` | Um lote representa uma importação efetiva e deve conter pelo menos um contrato. |
| `LOTE_IMPORTACAO` | 1 : 0..N | `INSTANCIA_IMPORTACAO` | Um lote pode existir antes do retorno do CSLOG. Após o envio aceito, deve possuir ao menos uma instância/ticket. |

## Relação muitos-para-muitos resolvida

Conceitualmente, `CONTRATO` e `LOTE_IMPORTACAO` possuem uma relação N:N. Ela foi normalizada pela entidade associativa `CONTRATO_LOTE_IMPORTACAO`, que contém:

- `id_contrato_lote` — chave primária;
- `id_contrato` — chave estrangeira para `CONTRATO`;
- `id_lote` — chave estrangeira para `LOTE_IMPORTACAO`;
- `status_importacao` — situação do contrato dentro daquele lote;
- `importado_em` — data e hora da importação, quando concluída;
- restrição única em `(id_contrato, id_lote)`.

## Decisões de fidelidade ao processo real

- `CONTRATO` representa a unidade processada pela automação e substitui a necessidade de `PROCESSAMENTO_CONTRATO`.
- `EVENTO_EXECUCAO` permanece no modelo porque registra a trilha de auditoria, mudanças de estado, worker associado, mensagens e o contrato relacionado quando aplicável.
- `total_contratos`, `contratos_sucesso` e `contratos_erro` permanecem em `EXECUCAO` como métricas-resumo persistidas.
- `qtd_workers` é um atributo derivado, não uma entidade independente.
- `total_contratos`, `total_linhas` e `qtd_instancias` permanecem em `LOTE_IMPORTACAO` como métricas-resumo da operação de CRM.
- `INSTANCIA_IMPORTACAO` permite acompanhar separadamente cada ticket/instância criado para um lote.
- O modelo não afirma integração ao vivo ou implantação em ambiente produtivo; ele representa a estrutura observada no projeto local e a simplificação acadêmica aprovada.
