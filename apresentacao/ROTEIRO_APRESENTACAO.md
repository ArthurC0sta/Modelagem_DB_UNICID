# Roteiro do pitch — Entrega 2 QORE

Tempo-alvo: **8 minutos**. Use os slides como apoio visual e não leia o texto.

| Slide | Tempo | Fala principal |
|---|---:|---|
| 1. Capa | 0:20 | Apresentar o grupo e o objetivo: banco para o ciclo completo dos serviços da QORE. |
| 2. Contexto | 0:55 | Explicar os volumes e a dificuldade de ligar chamado, contrato, projeto, entrega e resultado. |
| 3. Solução | 0:55 | Mostrar o fluxo organizacional e como o banco preserva o contexto. |
| 4. DER | 0:55 | Defender as 17 entidades, 19 relacionamentos e a separação entre contratos comercial e técnico. |
| 5. Modelo lógico | 1:05 | Explicar PKs, FKs, associativas e nulabilidade. |
| 6. SQL | 1:05 | Informar que o script executou do zero em MySQL 8.4 e mostrar a estrutura da consulta. |
| 7. Consultas | 1:05 | Relacionar consultas Gxx aos problemas e consultas Axx às regras de auditoria. |
| 8. BI e IA | 0:45 | Apresentar indicadores calculáveis e limitar IA a histórico anonimizado e validado. |
| 9. Benefícios | 0:55 | Resumir os benefícios, anunciar a demonstração e abrir para perguntas. |

## Demonstração SQL

Executar o arquivo `docs/qore_entrega_2.sql` num banco vazio. Em seguida, destacar:

1. `G04`: projetos ativos e responsáveis;
2. `G07`: taxa de sucesso da automação;
3. `G09`: lotes e instâncias pendentes;
4. `A07`: consistência entre totais da execução e contratos processados.

As consultas de auditoria devem retornar zero linhas na massa final.

## Defesa do modelo

- `CONTRATO_SERVICO` representa a contratação comercial; `CONTRATO_PROCESSADO` representa a unidade técnica consultada.
- `ALOCACAO_PROJETO` e `PARTICIPACAO_LOTE` resolvem N:N e armazenam atributos próprios.
- FKs opcionais em `CHAMADO` permitem registrar uma demanda antes de existir projeto ou entrega.
- Não há exclusão em cascata porque contratos, projetos, entregas, eventos e importações precisam manter histórico.
- KPIs são calculados por consultas para evitar redundância e inconsistência.
