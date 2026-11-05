# Validação do script MySQL

## Ambiente

- Data da validação: 05/11/2026, horário civil de São Paulo
- SGBD: MySQL Community Server 8.4.13
- Ambiente: contêiner Docker local e descartável
- Script: `docs/qore_entrega_2.sql`
- Estado inicial: banco inexistente

## Resultado

O script completo executou com código de saída `0`, criou o banco, inseriu a massa e executou as consultas gerenciais e de auditoria.

| Verificação | Resultado |
|---|---:|
| Tabelas criadas | 17 |
| Chaves estrangeiras | 25 |
| Restrições `CHECK` | 33 |
| Consultas gerenciais | 10 |
| Consultas de auditoria | 10 |
| Violações encontradas na massa final | 0 |

### Volumes representativos confirmados

| Entidade | Registros fictícios |
|---|---:|
| Clientes ativos | 7 |
| Projetos ativos | 21 |
| Chamados | 101 |

## Correção realizada durante o teste

A primeira massa declarava totais consolidados de execução maiores que a quantidade de contratos de demonstração. A auditoria `A07` identificou a divergência. Em uma revisão posterior, a auditoria `A05` também encontrou projetos ativos sem equipe. Os totais foram alinhados às linhas inseridas, os projetos foram distribuídos entre os contratos dos sete clientes e todos receberam alocação. A execução integral final retornou zero violações nas consultas `A01` a `A10`.

## Limite da evidência

Esta validação comprova execução local no MySQL 8.4.13. Ela não representa implantação em produção ou no laboratório da instituição. O grupo deve repetir a execução no equipamento usado na apresentação e capturar a tela das consultas escolhidas para a demonstração.
