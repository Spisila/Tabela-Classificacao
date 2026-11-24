-- Camada 3: Maybe, Either e formatacao

module Leitura where

import Data.Char (isSpace)
import Data.List (groupBy, intercalate, sort)
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

data Alinhamento = Esquerda | Direita

type Coluna = (String, Alinhamento, Linha -> String)

alinharEsquerda :: Int -> String -> String
alinharEsquerda largura texto =
  texto ++ replicate (largura - length texto) ' '

alinharDireita :: Int -> String -> String
alinharDireita largura texto =
  replicate (largura - length texto) ' ' ++ texto

alinhar :: Alinhamento -> Int -> String -> String
alinhar Esquerda = alinharEsquerda
alinhar Direita = alinharDireita

colunasTabela :: [Coluna]
colunasTabela =
  [ ("Time", Esquerda, time)
  , ("P", Direita, show . pontosLinha)
  , ("J", Direita, show . jogos)
  , ("V", Direita, show . vitorias)
  , ("E", Direita, show . empates)
  , ("D", Direita, show . derrotas)
  , ("SG", Direita, show . saldo)
  ]

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
      -> do
        validarCampos campos contexto
        validarTimes mandanteTexto visitanteTexto contexto
        rodadaAtual <- lerNumero contexto rodadaTexto
        golsMandanteAtual <- lerNumero contexto golsMandanteTexto
        golsVisitanteAtual <- lerNumero contexto golsVisitanteTexto
        validarPlacar golsMandanteAtual golsVisitanteAtual contexto
        Right (Partida rodadaAtual mandanteTexto
          golsMandanteAtual golsVisitanteAtual visitanteTexto)
    _ -> Left (CamposInvalidos contexto)

lerNumero :: String -> String -> Either Erro Int
lerNumero linha campo =
  maybe (Left (NumeroInvalido linha)) Right (readMaybe campo)

validarCampos :: [String] -> String -> Either Erro ()
validarCampos campos contexto =
  case campos of
    [_, _, _, _, _]
      | all (not . null) campos -> Right ()
      | otherwise -> Left (CamposInvalidos contexto)
    _ -> Left (CamposInvalidos contexto)

validarTimes :: Time -> Time -> String -> Either Erro ()
validarTimes mandante visitante contexto
  | mandante == visitante = Left (MesmoTime contexto)
  | otherwise = Right ()

validarPlacar :: Int -> Int -> String -> Either Erro ()
validarPlacar golsMandante golsVisitante contexto
  | golsMandante < 0 || golsVisitante < 0 =
      Left (PlacarNegativo contexto)
  | otherwise = Right ()

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
    ocorrencias = sort
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
  unlines
    (cabecalhoTabela larguras : divisoriaTabela larguras :
     map (formatarLinhaTabela larguras) (zip ([1..] :: [Int]) linhas))
  where
    larguras = largurasTabela linhas

largurasTabela :: [Linha] -> (Int, [Int])
largurasTabela linhas =
  (larguraPosicao, map (larguraColuna linhas) colunasTabela)
  where
    larguraPosicao = max (length "Pos") (length (show (length linhas)))

larguraColuna :: [Linha] -> Coluna -> Int
larguraColuna linhas (cabecalho, _, extrair) =
  maximum (length cabecalho : map (length . extrair) linhas)

cabecalhoTabela :: (Int, [Int]) -> String
cabecalhoTabela (larguraPosicao, larguras) =
  intercalate "  "
    (alinharDireita larguraPosicao "Pos" :
     zipWith formatoCabecalho larguras colunasTabela)

formatoCabecalho :: Int -> Coluna -> String
formatoCabecalho largura (cabecalho, alinhamento, _) =
  alinhar alinhamento largura cabecalho

divisoriaTabela :: (Int, [Int]) -> String
divisoriaTabela (larguraPosicao, larguras) =
  intercalate "  "
    (replicate larguraPosicao '-' :
     map (`replicate` '-') larguras)

formatarLinhaTabela :: (Int, [Int]) -> (Int, Linha) -> String
formatarLinhaTabela (larguraPosicao, larguras) (posicao, linha) =
  intercalate "  "
    (alinharDireita larguraPosicao (show posicao) :
     zipWith (formatoLinha linha) larguras colunasTabela)

formatoLinha :: Linha -> Int -> Coluna -> String
formatoLinha linha largura (_, alinhamento, extrair) =
  alinhar alinhamento largura (extrair linha)