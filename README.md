---
author:
- Felipe Quaresma e Marcelo Schreiber
date: Novembro 2023
title: Alocação de memória com brk em assembly x86-64 - Software Básico
---

## Estratégias de Implementação

A implementação da alocação de memória utilizando a syscall `brk` e o
algoritmo *first fit* foi conduzida de forma abstraída, focando em
aspectos essenciais para o entendimento do código em assembly x86-64.

## Setup Brk

Na função `setup_brk`, chama-se a syscall `brk` com 0 no argumento para
retornar o final da *heap*, com isso coloca este ponteiro as duas
variáveis globais.

## Dismiss Brk

Para a função `dismiss_brk`, optou-se por utilizar a syscall `brk`
novamente, desta vez definindo o `brk` de volta para o valor inicial
(`brk_inicial`).

## Memory Alloc

A estratégia de alocação de memória (`memory_alloc`) segue o algoritmo
*first fit*. Decidiu-se utilizar um loop para percorrer os blocos livres
disponíveis no heap. Quando um bloco adequado é encontrado, ele é
marcado como ocupado e seu endereço é retornado. Se não é encontraddo
aloca-se um novo com a utilização do `brk`.

## Memory Free

Para a função `memory_free`, verifica-se caso o endereço fornecido está
dentro dos limites do heap e se o bloco correspondente está marcado como
ocupado. Se todas as condições são atendidas, o bloco é marcado como
livre, permitindo sua posterior reutilização.
