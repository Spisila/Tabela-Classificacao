-- Camada 3: Maybe, Either e formatacao

module Leitura where

import Data.Char (isSpace)
import Data.List (groupBy, intercalate, sortOn)
import Data.Maybe (mapMaybe)
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
      campos = map removerEspacos (separar ';' linha)
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
    lerNumero linha campo =
      case readMaybe campo of
        Just valor -> Right valor
        Nothing -> Left (NumeroInvalido linha)

removerEspacos :: String -> String
removerEspacos = reverse . dropWhile isSpace . reverse . dropWhile isSpace

lerCampeonato :: String -> [[String]]
lerCampeonato campeonato = map (separar ';') (separar '\n' campeonato)

todosOsErros :: String -> [Erro]
todosOsErros texto =
  let linhas = filter (not . ignorar) (zip [1..] (lines texto))
      resultados = map (uncurry lerPartida) linhas
      errosDeLeitura = [erro | Left erro <- resultados]
      partidasValidas = [partida | Right partida <- resultados]
  in errosDeLeitura ++ errosDeRepeticao partidasValidas
  where
    ignorar (_, linha) =
      let limpa = removerEspacos linha
      in null limpa || head limpa == '#'

    errosDeRepeticao partidas =
      mapMaybe erroDeGrupo grupos
      where
        ocorrencias = sortOn id
          [ (rodada partida, nome)
          | partida <- partidas
          , nome <- [mandante partida, visitante partida]
          ]
        grupos = groupBy (==) ocorrencias

        erroDeGrupo grupo =
          case grupo of
            ((rodadaAtual, nome):_) 
              | length grupo > 1 ->
                  Just (TimeRepetidoNaRodada rodadaAtual nome)
            _ -> Nothing

tabelaFormatada :: [Linha] -> String
tabelaFormatada linhas =
  unlines (cabecalho : map formatarLinha (zip ([1..] :: [Int]) linhas))
  where
    cabecalho = intercalate " | "
      ["Pos", "Time", "P", "J", "V", "E", "D", "SG"]

    formatarLinha (posicao, linha) = intercalate " | "
      [ show posicao
      , time linha
      , show (3 * vitorias linha + empates linha)
      , show (jogos linha)
      , show (vitorias linha)
      , show (empates linha)
      , show (derrotas linha)
      , show (golsPro linha - golsContra linha)
      ]