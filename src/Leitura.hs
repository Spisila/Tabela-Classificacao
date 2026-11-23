-- Camada 3: Maybe, Either e formatacao

module Leitura where

import Data.Char (isSpace)
import Data.List (groupBy, intercalate, sortOn)
import Data.Maybe (mapMaybe)
import Text.Read (readMaybe)
import Classificacao (pontosLinha, saldo)
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
    [rodadaTexto, mandanteTexto, golsMandanteTexto, golsVisitanteTexto, visitanteTexto]
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
      maybe (Left (NumeroInvalido linha)) Right (readMaybe campo)

removerEspacos :: String -> String
removerEspacos = reverse . dropWhile isSpace . reverse . dropWhile isSpace

lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasDeEntrada texto)
  case errosDeRepeticao partidas of
    []       -> Right partidas
    erro : _ -> Left erro

todosOsErros :: String -> [Erro]
todosOsErros texto =
  let resultados = map (uncurry lerPartida) (linhasDeEntrada texto)
      errosDeLeitura = [erro | Left erro <- resultados]
      partidasValidas = [partida | Right partida <- resultados]
  in errosDeLeitura ++ errosDeRepeticao partidasValidas

linhasDeEntrada :: String -> [(Int, String)]
linhasDeEntrada texto =
  filter (not . ignorarLinha) (zip ([1..] :: [Int]) (lines texto))

ignorarLinha :: (Int, String) -> Bool
ignorarLinha (_, linha) =
  case removerEspacos linha of
    []     -> True
    '#':_  -> True
    _      -> False

errosDeRepeticao :: [Partida] -> [Erro]
errosDeRepeticao partidas = mapMaybe erroDeGrupo grupos
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
  unlines (cabecalho : divisoria : map formatarLinha (zip ([1..] :: [Int]) linhas))
  where
    larguraPosicao = max (length "Pos") (length (show (length linhas)))
    larguraTime = maximum (length "Time" : map (length . time) linhas)
    larguraPontos = maximum (length "P" : map (length . show . pontosLinha) linhas)
    larguraJogos = maximum (length "J" : map (length . show . jogos) linhas)
    larguraVitorias = maximum (length "V" : map (length . show . vitorias) linhas)
    larguraEmpates = maximum (length "E" : map (length . show . empates) linhas)
    larguraDerrotas = maximum (length "D" : map (length . show . derrotas) linhas)
    larguraSaldo = maximum (length "SG" : map (length . show . saldo) linhas)

    cabecalho = intercalate "  "
      [ alinharDireita larguraPosicao "Pos"
      , alinharEsquerda larguraTime "Time"
      , alinharDireita larguraPontos "P"
      , alinharDireita larguraJogos "J"
      , alinharDireita larguraVitorias "V"
      , alinharDireita larguraEmpates "E"
      , alinharDireita larguraDerrotas "D"
      , alinharDireita larguraSaldo "SG"
      ]

    divisoria = intercalate "  "
      [ replicate larguraPosicao '-'
      , replicate larguraTime '-'
      , replicate larguraPontos '-'
      , replicate larguraJogos '-'
      , replicate larguraVitorias '-'
      , replicate larguraEmpates '-'
      , replicate larguraDerrotas '-'
      , replicate larguraSaldo '-'
      ]

    formatarLinha (posicao, linha) = intercalate "  "
      [ alinharDireita larguraPosicao (show posicao)
      , alinharEsquerda larguraTime (time linha)
      , alinharDireita larguraPontos (show (pontosLinha linha))
      , alinharDireita larguraJogos (show (jogos linha))
      , alinharDireita larguraVitorias (show (vitorias linha))
      , alinharDireita larguraEmpates (show (empates linha))
      , alinharDireita larguraDerrotas (show (derrotas linha))
      , alinharDireita larguraSaldo (show (saldo linha))
      ]

    alinharEsquerda largura texto =
      texto ++ replicate (largura - length texto) ' '

    alinharDireita largura texto =
      replicate (largura - length texto) ' ' ++ texto