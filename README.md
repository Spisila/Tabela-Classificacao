# Tabela de Classificação de Campeonato

Projeto em Haskell para calcular a classificação de um campeonato de futebol
a partir dos resultados de suas partidas.

## Estrutura

- `src/Tipos.hs`: tipos do domínio e consultas sobre partidas.
- `src/Classificacao.hs`: cálculo dos pontos, classificação e estatísticas.
- `src/Leitura.hs`: leitura, validação, erros e formatação da tabela.
- `src/Dados.hs`: campeonato de teste em formato de texto.
- `src/Main.hs`: demonstração do programa.
- `tests/Testes.hs`: testes das três camadas.
- `docs/decisoes.md`: decisões de modelagem.
- `extra/enunciado.md`: especificação completa do trabalho.

## Ambiente

O projeto foi preparado para execução com GHC local, instalado pelo GHCup ou
pela distribuição disponível no sistema.

Não são necessárias bibliotecas externas além da biblioteca padrão.

## Compilação

Na pasta raiz do projeto, execute:

```text
ghc -Wall -isrc src/Main.hs -o tabela
```

Para verificar os testes:

```text
ghc -Wall -isrc tests/Testes.hs -o testes
```

No Windows, os executáveis gerados são `tabela.exe` e `testes.exe`.

## Execução

No Linux ou macOS:

```text
./tabela
./testes
```

No Windows:

```text
.\tabela.exe
.\testes.exe
```

Também é possível executar sem gerar arquivos de saída:

```text
runghc -isrc src/Main.hs
runghc -isrc tests/Testes.hs
```

Para abrir o programa no GHCi:

```text
ghci -isrc src/Main.hs
```

## O que o programa demonstra

- Tabela completa do campeonato.
- Tabela após a 3ª rodada.
- Média de gols por partida.
- Partida com maior diferença de gols.
- Relatório de uma entrada inválida.

## Saída esperada dos testes

Cada teste aprovado aparece como:

```text
OK: nome do teste
```

Caso um resultado esteja incorreto, o programa informa o nome do teste,
o valor obtido e o valor esperado.