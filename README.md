# Entrega 1 - Modelagem de Banco de Dados

## Automação de Consulta de Contratos Accenture C6

Trabalho acadêmico desenvolvido para a disciplina **Modelagem de Banco de Dados**, do curso de **Ciência da Computação da UNICID**, sob orientação do professor **Cid Rodrigues**.

## Autores

- Arthur Costa - RGM 46677259
- Felipe Pereira Vescia - RGM 46825576
- Roginer Haiz dos Santos - RGM 47632160

São Paulo - SP, 2026.

## Objetivo

Documentar o processo real da automação Accenture C6 e apresentar o levantamento de requisitos e o modelo conceitual do banco de dados. O projeto contempla processo e fluxograma, requisitos funcionais e não funcionais, regras de negócio, entidades, atributos, relacionamentos, cardinalidades, dicionário de dados, DER e justificativa técnica.

## Arquivos para avaliacao

- [Relatorio final em PDF](output/pdf/RELATORIO_ENTREGA_1_MODELAGEM_ACCENTURE_C6.pdf)
- [DER em PNG](output/der/DER_ACCENTURE_C6.png)
- [DER em SVG](output/der/DER_ACCENTURE_C6.svg)
- [Cardinalidades](output/der/CARDINALIDADES_ACCENTURE_C6.md)
- [Registro da empresa consultada](output/assets/EQUIPE_QORE_EMPRESA_CONSULTADA.png)

## Recorte do modelo

O modelo acadêmico utiliza sete entidades:

1. `AUTOMACAO`
2. `EXECUCAO`
3. `CONTRATO`
4. `EVENTO_EXECUCAO`
5. `LOTE_IMPORTACAO`
6. `INSTANCIA_IMPORTACAO`
7. `CONTRATO_LOTE_IMPORTACAO`

`WORKER`, `PROCESSAMENTO_CONTRATO` e `MOVIMENTO_CSLOG` foram mantidos fora do DER conforme as decisões de escopo justificadas no relatório.

## Empresa consultada

A empresa consultada foi a **QORE**. O registro presente no relatório identifica Leonardo Queiroz (CEO), Renan Medeiros (Tech Lead) e Arthur Costa (Dev).

## Uso de inteligência artificial

Este trabalho contou com apoio de ferramenta de inteligência artificial generativa na organização do conteúdo, revisão textual, estruturação das seções e geração do PDF. As decisões de escopo e modelagem foram revisadas pelos autores a partir do processo e da documentação analisados.

## Cuidados com os dados

O repositório de entrega não deve conter credenciais, tokens, cookies, bancos operacionais nem dados identificáveis de contratos.
