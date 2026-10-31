-- Camada 3: Maybe, Either e formatacao

module Leitura where

import Tipos

data Erro
  = CamposInvalidos String
  | NumeroInvalido String
  | PlacarNegativo String
  | MesmoTime String
  | TimeRepetidoNaRodada Int Time

separar :: Char -> String -> [String]
separar c s = 
  let (palavra, resto) = break (== c) s
  in case resto of
    []     -> [palavra]
    (_:xs) -> palavra : separar c xs

-- lerPartida :: Int -> String -> Either Erro Partida

-- lerCampeonato :: String -> Either Erro [Partida]

-- todosOsErros :: String -> [Erro]

-- tabelaFormatada :: [Linha] -> String