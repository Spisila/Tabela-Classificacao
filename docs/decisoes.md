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
- Os tipos fechados dificultam estados invalidos: `Resultado` limita o
  resultado a `Vitoria`, `Empate` ou `Derrota`, e nao aceita representacoes
  soltas como String ou Int. `Partida` e `Linha` usam records, o que mantem
  nomes associados aos campos e evita trocar mandante e visitante sem
  perceber. Uma `Partida` criada por `lerCampeonato` ja passou pelas
  validacoes de campos vazios, placar negativo, time contra si mesmo e time
  repetido na rodada. Ainda assim, quem monta uma `Partida` diretamente pode
  criar um placar negativo, pois o construtor nao impede isso.

## Camada 2

- `linhaDoTime` usa `foldl` da esquerda para a direita sobre as partidas ja
  filtradas, acumulando jogos, resultados e gols em uma unica `Linha`. Como
  por time existem poucas partidas, nao ha problema relevante de laziness, e
  essa ordem mantem a leitura cronologica das partidas.
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
- Quando dois times empatam em pontos, vitorias, saldo e gols pro, a ordem
  e decidida pelo nome em ordem alfabetica, apenas para tornar a tabela
  deterministica; esse criterio nao e oficial do campeonato. Por exemplo,
  Atletico-MG e Criciuma terminam com 9 pontos, 2 vitorias, saldo 5 e 8 gols
  pro; Atletico-MG fica na frente apenas pelo nome.
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

## Casos de borda e armadilhas do enunciado

| Armadilha | Como foi evitada | Onde/teste |
|---|---|---|
| Tupla em vez de record | `Partida` e `Linha` usam records com campos nomeados | Camada 1 em `Tipos.hs` |
| `Resultado` como String ou Int | Foi usado o tipo soma `Resultado` com tres construtores fechados | `resultadoPara` e testes "resultado do mandante", "resultado do visitante" |
| `head`, `maximum` ou `foldr1` em lista vazia | `maiorGoleada` e `mediaGols` usam `Maybe`; os `maximum` de `tabelaFormatada` comecam pelo comprimento do cabecalho, portanto a lista nunca fica vazia | Testes "maior goleada em lista vazia", "media de gols em lista vazia", "tabela vazia contem somente cabecalho e divisoria" |
| `div` ou `Int` com `/` | O aproveitamento converte os pontos e jogos com `fromIntegral` antes da divisao | Teste "aproveitamento da linha" |
| Ordenar apenas por pontos ou encadear varios `sortBy` | A comparacao usa um unico `criterio` encadeado com `comparing`, `Down` e `<>` | Testes "desempate por saldo Athletico-PR Bahia Cruzeiro", "desempate por vitorias Botafogo Atletico-MG", "desempate por gols pro criterio Linha A Linha B" |
| Recursao explicita na Camada 2 | `map`, `filter`, `foldl`, `sortBy` e `sum` substituem recursao explicita | `linhaDoTime`, `classificacao`, `ateRodada` e as propriedades da Camada 2 |
| `read` em vez de `readMaybe` | As conversoes usam `readMaybe`; `maybe` converte `Nothing` em `NumeroInvalido` | Testes "numero invalido", "ler partida com espacos", "todos os erros conta comentarios e linhas vazias" |
| Cases aninhados em `Either` | `lerPartida` usa `do` em `Either`; `lerCampeonato` usa `traverse` | Testes "campos invalidos", "mesmo time", "placar negativo", "time repetido na rodada" |
| `getLine` no `main` | Os dados ficam em `dadosCampeonato`, como String; o `main` nao faz entrada pelo teclado | Testes "campeonato vazio como texto", "ler campeonato ignora comentario e linha vazia" |
| Campeonato vazio | `lerCampeonato ""` retorna `Right []`, `classificacao []` retorna `[]` e a tabela vazia mostra apenas cabecalho e divisoria | Testes "campeonato vazio como texto", "campeonato vazio com comentario", "classificacao de campeonato vazio", "tabela vazia contem somente cabecalho e divisoria" |

Observacao: `main` em `src/Main.hs` e a unica funcao com `IO` no codigo do
programa. O modulo `tests/Testes.hs` usa `IO` apenas porque executa e imprime
os resultados dos testes.

## Decisoes gerais

- Mantivemos os modulos separados por camada para que tipos, calculos,
  entrada e demonstracao possam ser testados independentemente.
- O ambiente escolhido para executar o projeto e o GHC local, instalado via
  GHCup. Os modulos ficam separados em `src/`.
- Os dados do campeonato ficam em `dadosCampeonato`, em `Dados.hs`, como uma
  `String`, para nao depender de entrada pelo teclado.
- O `main` apenas coordena a demonstracao e depende de funcoes puras para
  obter a classificacao e os erros.

## Limitacoes conhecidas

- O programa nao faz leitura interativa nem recebe o campeonato por argumento
  de linha de comando.
- Rodadas negativas nao sao consideradas explicitamente invalidas por
  `lerPartida`; elas podem entrar como valores numericos validos.
- Confronto direto, cartoes e outros criterios oficiais nao foram
  implementados. Os criterios definidos foram pontos, vitorias, saldo,
  gols pro e nome do time.
- Os nomes de time diferenciam maiusculas e minusculas. Espacos internos nos
  nomes nao sao normalizados.
- Rodadas nao precisam ser consecutivas e o programa nao verifica se o
  calendario esta completo.
- O aproveitamento e retornado como `Double`, sem arredondamento.
- Os dados de teste nao usam acentos para evitar problemas de codificacao no
  console do Windows.