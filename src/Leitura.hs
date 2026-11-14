-- Camada 3: Maybe, Either e formatacao

module Leitura where

import Data.Char (isSpace)
import Text.Read (readMaybe)
import Tipos

data Erro
  = CamposInvalidos String
  | NumeroInvalido String
  | PlacarNegativo String
  | MesmoTime String
  | TimeRepetidoNaRodada Int Time
  deriving (Show, Eq)

removerQuebra :: String -> String
removerQuebra s = filter (/= '\n') s

separar :: Char -> String -> [String]
separar char string = 
  let (palavra, resto) = break (== char) string
  in case resto of
    []     -> [palavra]
    (_:xs) -> palavra : separar char xs

lerPartida :: Int -> String -> Either Erro Partida
lerPartida numeroLinha texto =
  let linha = removerQuebra texto
      campos = map limpar (separar ';' linha)
      contexto = "linha " ++ show numeroLinha ++ ": " ++ linha
  in case campos of
    [rodadaTexto, mandanteTexto, golsMandanteTexto,
      golsVisitanteTexto, visitanteTexto]
        | any null campos -> Left (CamposInvalidos contexto)
        | mandanteTexto == visitanteTexto -> Left (MesmoTime contexto)
        | otherwise -> do
            rodadaAtual <- lerNumero contexto rodadaTexto
            golsMandanteAtual <- lerNumero contexto golsMandanteTexto
            golsVisitanteAtual <- lerNumero contexto golsVisitanteTexto
            if golsMandanteAtual < 0 || golsVisitanteAtual < 0
              then Left (PlacarNegativo contexto)
              else Right (Partida rodadaAtual mandanteTexto
                    golsMandanteAtual golsVisitanteAtual visitanteTexto)
    _ -> Left (CamposInvalidos contexto)
  where
    limpar = reverse . dropWhile isSpace . reverse . dropWhile isSpace

    lerNumero linha campo =
      case readMaybe campo of
        Just valor -> Right valor
        Nothing -> Left (NumeroInvalido linha)

lerCampeonato :: String -> [[String]]
lerCampeonato campeonato = map (separar ';') (separar '\n' campeonato)

-- todosOsErros :: String -> [Erro]

-- tabelaFormatada :: [Linha] -> String