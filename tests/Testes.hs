-- Testes com resultado esperado

module Main where

import Classificacao
import Dados
import Leitura
import Tipos

testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK: " ++ nome)
  | otherwise = putStrLn
      ("FALHOU: " ++ nome ++ "\n  obtido: " ++ show obtido
        ++ "\n  esperado: " ++ show esperado)

partidaTeste :: Partida
partidaTeste = Partida 1 "Time A" 2 1 "Time B"

partidasDoCampeonato :: [Partida]
partidasDoCampeonato =
  case lerCampeonato dadosCampeonato of
    Right partidas -> partidas
    Left erro -> error ("Dados de teste invalidos: " ++ show erro)

nomesClassificacaoFinal :: [Time]
nomesClassificacaoFinal =
  [ "Athletico-PR", "Bahia", "Cruzeiro", "Botafogo", "Atletico-MG"
  , "Criciuma", "Red Bull Bragantino", "Palmeiras", "Flamengo"
  , "Juventude", "Sao Paulo", "Internacional", "Fortaleza", "Gremio"
  , "Corinthians", "Fluminense", "Vitoria", "Vasco", "Atletico-GO"
  , "Cuiaba"
  ]

nomesClassificacaoAteTerceira :: [Time]
nomesClassificacaoAteTerceira =
  [ "Red Bull Bragantino", "Flamengo", "Botafogo", "Athletico-PR"
  , "Gremio", "Internacional", "Atletico-MG", "Fortaleza", "Vitoria"
  , "Bahia", "Fluminense", "Palmeiras", "Cruzeiro", "Juventude"
  , "Sao Paulo", "Vasco", "Criciuma", "Corinthians", "Atletico-GO"
  , "Cuiaba"
  ]

erroEh :: (Erro -> Bool) -> Either Erro a -> Bool
erroEh predicado resultado =
  case resultado of
    Left erro -> predicado erro
    Right _ -> False

testesCamada1 :: IO ()
testesCamada1 = do
  testar "campeonato vazio como texto"
    (lerCampeonato "") (Right [])
  testar "campeonato vazio com comentario"
    (lerCampeonato "# só comentário\n\n") (Right [])
  testar "resultado do mandante"
    (resultadoPara "Time A" partidaTeste) (Just Vitoria)
  testar "resultado do visitante"
    (resultadoPara "Time B" partidaTeste) (Just Derrota)
  testar "resultado de time ausente"
    (resultadoPara "Time C" partidaTeste) Nothing
  testar "times sem repeticao e em ordem alfabetica"
    (times [partidaTeste, Partida 2 "Time C" 0 0 "Time A"])
    ["Time A", "Time B", "Time C"]
  testar "campeonato valido"
    (case lerCampeonato dadosCampeonato of
       Right _ -> True
       Left _ -> False)
    True

testesCamada2 :: IO ()
testesCamada2 = do
  let final = classificacao partidasDoCampeonato
      ateTerceira = classificacao (ateRodada 3 partidasDoCampeonato)
      linhaSemJogos = Linha "Time C" 0 0 0 0 0 0
      linhaComResultados = Linha "Time A" 3 1 1 1 5 3
  testar "media de gols do campeonato real"
    (mediaGols partidasDoCampeonato) (Just 2.3)
  -- Empate em diferença 4: as três partidas são Athletico-PR 4x0 Cuiaba,
  -- Botafogo 5x1 Juventude e Vasco 0x4 Criciuma. Nesta lista de partidas,
  -- sortBy preserva a primeira como vencedor do empate.
  testar "maior goleada do campeonato real"
    (maiorGoleada partidasDoCampeonato)
    (Just (Partida 1 "Athletico-PR" 4 0 "Cuiaba"))
  testar "linha do Athletico-PR no campeonato completo"
    (linhaDoTime partidasDoCampeonato "Athletico-PR")
    (Linha "Athletico-PR" 5 3 1 1 7 3)
  testar "linha do time em lista vazia"
    (linhaDoTime [] "Qualquer")
    (Linha "Qualquer" 0 0 0 0 0 0)
  testar "classificacao de campeonato vazio"
    (classificacao []) []
  testar "pontos para vitoria"
    (pontos Vitoria) 3
  testar "pontos para empate"
    (pontos Empate) 1
  testar "pontos para derrota"
    (pontos Derrota) 0
  testar "pontos da linha"
    (pontosLinha linhaComResultados) 4
  testar "saldo de gols da linha"
    (saldo linhaComResultados) 2
  testar "aproveitamento da linha"
    (aproveitamento linhaComResultados) (400 / 9)
  testar "aproveitamento sem jogos"
    (aproveitamento linhaSemJogos) 0
  testar "classificacao final completa"
    (map time final) nomesClassificacaoFinal
  testar "classificacao ate a terceira rodada"
    (map time ateTerceira) nomesClassificacaoAteTerceira
  testar "classificacoes intermediaria e final diferentes"
    (map time ateTerceira /= map time final) True
  testar "desempate por saldo de gols"
    (take 3 (map time final))
    ["Athletico-PR", "Bahia", "Cruzeiro"]
  testar "maior goleada em lista vazia"
    (maiorGoleada []) Nothing
  testar "media de gols em lista vazia"
    (mediaGols []) Nothing

testesCamada3 :: IO ()
testesCamada3 = do
  let linhasManuais =
        [ Linha "Alpha" 2 1 1 0 3 1
        , Linha "Beta" 2 0 1 1 2 4
        ]
      tabelaManuaisEsperada =
        "Pos  Time   P  J  V  E  D  SG\n" ++
        "---  -----  -  -  -  -  -  --\n" ++
        "  1  Alpha  4  2  1  1  0   2\n" ++
        "  2  Beta   1  2  0  1  1  -2\n"
      entradaComErros = unlines
        [ "1;Time A;dois;0;Time B"
        , "2;Time C;-1;0;Time D"
        , "3;Time E;1;1;Time E"
        , "4;Time F;0;0"
        , "5;Time G;1;0;Time H"
        , "5;Time I;2;0;Time G"
        ]
  testar "separar com tres campos"
    (separar ';' "a;b;c") ["a","b","c"]
  testar "separar texto vazio"
    (separar ';' "") [""]
  testar "separar campos vazios internos"
    (separar ';' "a;;b") ["a","","b"]
  testar "tabela vazia contem somente cabecalho e divisoria"
    (tabelaFormatada [])
    ("Pos  Time  P  J  V  E  D  SG\n" ++
     "---  ----  -  -  -  -  -  --\n")
  testar "tabela formatada com duas linhas"
    (tabelaFormatada linhasManuais) tabelaManuaisEsperada
  testar "numero invalido"
    (erroEh numeroInvalido (lerPartida 1 "1;Time A;dois;0;Time B")) True
  testar "placar negativo"
    (erroEh placarNegativo (lerPartida 2 "1;Time A;-1;0;Time B")) True
  testar "mesmo time"
    (erroEh mesmoTime (lerPartida 3 "1;Time A;1;1;Time A")) True
  testar "campos invalidos"
    (erroEh camposInvalidos (lerPartida 4 "1;Time A;0;0")) True
  testar "time repetido na rodada"
    (erroEh timeRepetido (lerCampeonato
      "1;Time A;1;0;Time B\n1;Time C;2;0;Time A")) True
  testar "todos os erros da entrada"
    (todosOsErros entradaComErros)
    [ NumeroInvalido "linha 1: 1;Time A;dois;0;Time B"
    , PlacarNegativo "linha 2: 2;Time C;-1;0;Time D"
    , MesmoTime "linha 3: 3;Time E;1;1;Time E"
    , CamposInvalidos "linha 4: 4;Time F;0;0"
    , TimeRepetidoNaRodada 5 "Time G"
    ]
  where
    numeroInvalido erro =
      case erro of
        NumeroInvalido _ -> True
        _ -> False
    placarNegativo erro =
      case erro of
        PlacarNegativo _ -> True
        _ -> False
    mesmoTime erro =
      case erro of
        MesmoTime _ -> True
        _ -> False
    camposInvalidos erro =
      case erro of
        CamposInvalidos _ -> True
        _ -> False
    timeRepetido erro =
      case erro of
        TimeRepetidoNaRodada 1 "Time A" -> True
        _ -> False

main :: IO ()
main = do
  testesCamada1
  testesCamada2
  testesCamada3