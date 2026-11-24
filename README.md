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

## Ambiente

O projeto foi preparado para execução com GHC local, instalado pelo GHCup ou
pela distribuição disponível no sistema.

Testado com: GHC The Glorious Glasgow Haskell Compilation System, version 9.6.6, Windows

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

## Checklist dos requisitos do enunciado

| Requisito | Onde está | Teste |
|---|---|---|
| `type Time = String` | `src/Tipos.hs`: `Time` | Teste "times sem repeticao e em ordem alfabetica" |
| `data Resultado` com `Vitoria`, `Empate` e `Derrota` | `src/Tipos.hs`: `Resultado`; `src/Classificacao.hs`: `pontos` | Testes "pontos para vitoria", "pontos para empate", "pontos para derrota" |
| Record `Partida` com rodada, mandante, gols e visitante | `src/Tipos.hs`: `Partida` | Testes "resultado do mandante", "resultado do visitante", "resultado de time ausente" |
| Record `Linha` com time e estatisticas | `src/Tipos.hs`: `Linha`; `src/Classificacao.hs`: `linhaDoTime` | Testes "linha do Athletico-PR no campeonato completo", "linha do time em lista vazia" |
| `participou` | `src/Tipos.hs`: `participou` | Coberto por "linha do Athletico-PR no campeonato completo" |
| `resultadoPara` com `Maybe Resultado` | `src/Tipos.hs`: `resultadoPara` | Testes "resultado do mandante", "resultado do visitante", "resultado de time ausente" |
| `times` sem repeticao e em ordem alfabetica | `src/Tipos.hs`: `times` | Testes "times sem repeticao e em ordem alfabetica", "campeonato real tem pelo menos seis times" |
| `pontos` | `src/Classificacao.hs`: `pontos` | Testes "pontos para vitoria", "pontos para empate", "pontos para derrota" |
| `linhaDoTime` acumulada com dobra | `src/Classificacao.hs`: `linhaDoTime`, usa `foldl` | Testes "linha do Athletico-PR no campeonato completo", "linha do time em lista vazia" |
| `pontosLinha` e `saldo` | `src/Classificacao.hs`: `pontosLinha`, `saldo` | Testes "pontos da linha", "saldo de gols da linha" |
| `aproveitamento` com 0 sem jogos | `src/Classificacao.hs`: `aproveitamento` | Testes "aproveitamento da linha", "aproveitamento sem jogos" |
| `classificacao` completa e ordenada | `src/Classificacao.hs`: `classificacao`, `criterio` | Testes "classificacao final completa", "desempate por saldo Athletico-PR Bahia Cruzeiro", "desempate por vitorias Botafogo Atletico-MG", "desempate por nome Atletico-MG Criciuma", "desempate por gols pro criterio Linha A Linha B" |
| `ateRodada` | `src/Classificacao.hs`: `ateRodada` | Testes "ate rodada zero retorna lista vazia", "ate rodada tres tem trinta partidas", "ate rodada tres limita todas as rodadas", "ate rodada cinco retorna o campeonato inteiro" |
| `maiorGoleada` com `Maybe` | `src/Classificacao.hs`: `maiorGoleada` | Testes "maior goleada do campeonato real", "maior goleada em lista vazia" |
| `mediaGols` com `Maybe` | `src/Classificacao.hs`: `mediaGols` | Testes "media de gols do campeonato real", "media de gols em lista vazia" |
| Uso de `map`, `filter`, dobra e composicao `(.)` | `src/Classificacao.hs`: `linhaDoTime`, `classificacao`, `ateRodada`, `criterio` | Testes "classificacao final completa", "classificacao ate a terceira rodada", "linha do Athletico-PR no campeonato completo" |
| Ordenacao com `sortBy`, `comparing` e `Down` | `src/Classificacao.hs`: `sortBy`, `criterio` | Testes "desempate por saldo Athletico-PR Bahia Cruzeiro", "desempate por vitorias Botafogo Atletico-MG", "desempate por gols pro criterio Linha A Linha B" |
| Camada 2 sem recursao explicita | `src/Classificacao.hs`: funcoes por ordem superior e dobra | Testes "classificacao final completa", "linha do time em lista vazia" |
| `separar` | `src/Leitura.hs`: `separar` | Testes "separar com tres campos", "separar texto vazio", "separar campos vazios internos" |
| `lerPartida` com `do` em `Either` | `src/Leitura.hs`: `lerPartida`, `lerNumero`, validadores | Testes "ler partida com espacos", "ler partida com CRLF", "numero invalido", "placar negativo", "mesmo time", "campos invalidos" |
| `lerCampeonato` com `traverse` e validacao de repeticao | `src/Leitura.hs`: `lerCampeonato`, `errosDeRepeticao` | Testes "campeonato valido", "ler campeonato ignora comentario e linha vazia", "time repetido na rodada" |
| `todosOsErros` | `src/Leitura.hs`: `todosOsErros` | Testes "todos os erros conta comentarios e linhas vazias", "todos os erros da entrada" |
| `tabelaFormatada` com todas as colunas | `src/Leitura.hs`: `tabelaFormatada` | Testes "tabela vazia contem somente cabecalho e divisoria", "tabela formatada com duas linhas" |
| Cinco construtores de `Erro` | `src/Leitura.hs`: `Erro`, `CamposInvalidos`, `NumeroInvalido`, `PlacarNegativo`, `MesmoTime`, `TimeRepetidoNaRodada` | Testes "campos invalidos", "numero invalido", "placar negativo", "mesmo time", "time repetido na rodada" |
| Conversoes com `readMaybe`, nunca `read` | `src/Leitura.hs`: `lerNumero`, usa `readMaybe` e `maybe` | Testes "numero invalido", "todos os erros conta comentarios e linhas vazias" |
| Uso explicito de `Maybe` como functor/mônada | `src/Leitura.hs`: `maybe` em `lerNumero`; `src/Classificacao.hs`: `maybe` em `acumular` | Testes "resultado de time ausente", "media de gols em lista vazia", "numero invalido" |
| Bloco `do` em `Either` | `src/Leitura.hs`: `lerPartida` e `lerCampeonato` | Testes "ler partida com espacos", "campeonato valido", "time repetido na rodada" |
| Linhas vazias e comentarios ignorados | `src/Leitura.hs`: `linhasDeEntrada`, `ignorarLinha` | Testes "campeonato vazio como texto", "campeonato vazio com comentario", "ler campeonato ignora comentario e linha vazia", "todos os erros conta comentarios e linhas vazias" |
| `main` demonstra tabela final, rodada 3, estatisticas e erros | `src/Main.hs`: `main` | Testes "todos os erros da entrada", "classificacao ate a terceira rodada", "media de gols do campeonato real", "maior goleada do campeonato real" |
| Entradas invalidas sem excecao | `src/Leitura.hs`: `lerNumero` usa `readMaybe`; validadores retornam `Either` | Testes "numero invalido", "placar negativo", "mesmo time", "campos invalidos", "time repetido na rodada" |
| A unica funcao com IO e o main; testes usam IO pelo executor | `src/Main.hs`: `main`; `tests/Testes.hs`: `testar` e `main` | Testes de toda a bateria |
| Campeonato com 6+ times e 5+ rodadas | `src/Dados.hs`: `dadosCampeonato` | Testes "campeonato real tem pelo menos seis times", "campeonato real tem pelo menos cinco rodadas" |
| Partida empatada em `0 x 0` | `src/Dados.hs`: Corinthians 0 x 0 Atletico-MG | Teste "campeonato real tem partida empatada em zero" |
| Goleada por 3+ gols | `src/Dados.hs`: partidas com diferenca maior ou igual a 3 | Teste "campeonato real tem partida por tres gols ou mais" |
| Pelo menos dois times empatados em pontos e desempate real | `src/Dados.hs`; `src/Classificacao.hs`: `criterio` | Testes "campeonato final tem times consecutivos empatados em pontos", "desempate por saldo Athletico-PR Bahia Cruzeiro", "desempate por nome Atletico-MG Criciuma" |
| Estrutura de entrega da Secao 6 | `src/`, `tests/`, `docs/`, `README.md` | Testes "campeonato valido", "todos os erros da entrada", "tabela formatada com duas linhas" |
| Casos de teste obrigatorios da Camada 1 | `tests/Testes.hs`: `testesCamada1` | Testes "resultado do mandante", "resultado do visitante", "resultado de time ausente", "times sem repeticao e em ordem alfabetica" |
| Casos de teste obrigatorios da Camada 2 | `tests/Testes.hs`: `testesCamada2` | Testes "classificacao final completa", "desempate por saldo de gols", "classificacao ate a terceira rodada", "maior goleada em lista vazia", "media de gols em lista vazia" |
| Casos de teste obrigatorios da Camada 3 | `tests/Testes.hs`: `testesCamada3` | Testes "campeonato valido", "numero invalido", "placar negativo", "mesmo time", "campos invalidos", "time repetido na rodada", "todos os erros da entrada" |

## Como ler a saida

Exemplo curto da saida de `./testes`:

```text
OK: campeonato vazio como texto
OK: resultado do mandante
OK: resultado do visitante
...
```

Inicio da tabela final produzida por `./tabela`:

```text
=== Tabela final ===
Pos  Time                  P  J  V  E  D   SG
---  -------------------  --  -  -  -  -  --
  1  Athletico-PR         10  5  3  1  1    4
  2  Bahia                10  5  3  1  1    2
```