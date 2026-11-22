-- Demonstracao das tres camadas

module Main where

import Classificacao
import Dados
import Leitura

main :: IO ()
main = do
  putStrLn "=== Tabela final ==="
  case lerCampeonato dadosCampeonato of
    Left erro -> print erro
    Right partidas -> do
      putStrLn (tabelaFormatada (classificacao partidas))

      putStrLn "=== Tabela ate a 3a rodada ==="
      putStrLn (tabelaFormatada (classificacao (ateRodada 3 partidas)))

      putStrLn "=== Estatisticas ==="
      putStrLn ("Media de gols: " ++ show (mediaGols partidas))
      putStrLn ("Maior goleada: " ++ show (maiorGoleada partidas))

  putStrLn "=== Tratamento de uma entrada com erros ==="
  mapM_ print (todosOsErros dadosInvalidos)
  where
    dadosInvalidos = unlines
      [ "1;Time A;dois;0;Time B"
      , "2;Time C;-1;0;Time D"
      , "3;Time E;1;1;Time E"
      , "4;Time F;0;0"
      , "5;Time G;1;0;Time H"
      , "5;Time I;2;0;Time G"
      ]