# Decisoes de modelagem

## Camada 1

- Utilizamos records para representar `Partida` e `Linha`. Essa escolha evita
  confundir os gols do mandante com os gols do visitante e torna os campos
  mais legiveis.
- `Resultado` foi definido como um tipo soma com `Vitoria`, `Empate` e
  `Derrota`. Assim, o resultado de uma partida fica limitado a estados validos
  que o programa consegue distinguir.
- `resultadoPara` usa `Maybe Resultado`, pois uma partida pode nao envolver
  determinado time. Dessa forma, nao existe a necessidade de usar uma
  representacao especial para indicar que o time nao participou.
- `times` utiliza `nub` e `sort` para remover repeticoes e apresentar os nomes
  em ordem alfabetica.

## Camada 2

- `linhaDoTime` usa `foldl` para acumular jogos, resultados e gols em uma
  unica `Linha`. A lista de partidas do time ja foi filtrada antes da dobra,
  evitando processar partidas nas quais ele nao participou.
- Os pontos sao calculados separadamente por `pontosLinha`. Uma vitoria vale
  tres pontos e um empate vale um ponto.
- O aproveitamento usa a quantidade de pontos conquistados dividida pelos
  pontos disputados. Se o time nao jogou, a funcao retorna `0`.
- A classificacao usa uma unica comparacao encadeada com `comparing` e `<>`.
  Os criterios sao, nesta ordem:

  1. pontos;
  2. vitorias;
  3. saldo de gols;
  4. gols pro;
  5. nome do time como criterio final alfabetico.

  `Down` foi usado nos criterios em que valores maiores devem aparecer
  antes. O nome do time foi usado apenas como desempate final deterministico.
- `ateRodada` usa `filter`, permitindo reutilizar todas as funcoes de
  classificacao com os dados de uma rodada intermediaria.
- `maiorGoleada` e `mediaGols` devolvem `Maybe`, pois uma lista vazia nao
  possui goleada nem media. `listToMaybe` evita o uso de funcoes parciais.

## Camada 3

- Os campos da entrada sao separados por ponto e virgula e tem seus espacos
  laterais removidos antes da conversao.
- `lerPartida` usa notacao `do` com `Either` para encadear validacoes. O
  primeiro erro interrompe a conversao da linha.
- Todas as conversoes numericas usam `readMaybe`, evitando excecoes causadas
  por valores nao numericos.
- Linhas vazias e linhas cujo primeiro caractere nao espaco seja `#` sao
  ignoradas.
- `lerCampeonato` usa `traverse` para converter todas as linhas relevantes,
  parando no primeiro erro. Depois verifica se um time aparece mais de uma
  vez na mesma rodada.
- `todosOsErros` coleta os erros de leitura de todas as linhas e tambem os
  erros de repeticao. Assim, o usuario recebe um relatorio completo.
- Os erros carregam a linha ou a rodada correspondente, tornando as mensagens
  mais uteis e facilitando a localizacao do problema.

## Decisoes gerais

- Mantivemos os modulos separados por camada para que tipos, calculos,
  entrada e demonstracao possam ser testados independentemente.
- Os dados do campeonato ficam em `dadosCampeonato`, em `Dados.hs`, pois isso
  permite executar o projeto no GHC local e no playground sem entrada pelo
  teclado.
- O `main` apenas coordena a demonstracao e depende de funcoes puras para
  obter a classificacao e os erros.

## Limitacoes conhecidas

- O programa nao faz leitura interativa nem recebe o campeonato por argumento
  de linha de comando.
- Rodadas negativas nao sao consideradas explicitamente invalidas por
  `lerPartida`; elas podem entrar como valores numericos validos.
- O desempate por confronto direto nao foi implementado. Os criterios
  definidos foram pontos, vitorias, saldo, gols pro e nome do time.