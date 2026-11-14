-- Camada 1: tipos e consultas basicas

module Tipos where 

import Data.List (nub, sort)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq)

data Partida = Partida
  { rodada         :: Int
  , mandante       :: Time
  , golsMandante   :: Int
  , golsVisitante  :: Int
  , visitante      :: Time
  } deriving (Show, Eq)

data Linha = Linha
  { time      :: Time
  , jogos     :: Int
  , vitorias  :: Int
  , empates   :: Int
  , derrotas  :: Int
  , golsPro   :: Int
  , golsContra :: Int
  } deriving (Show, Eq)

participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

comparar :: Int -> Int -> Resultado
comparar a b
  | a > b     = Vitoria
  | a == b    = Empate
  | otherwise = Derrota

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | t == mandante p  = Just (comparar (golsMandante p) (golsVisitante p))
  | t == visitante p = Just (comparar (golsVisitante p) (golsMandante p))
  | otherwise        = Nothing

times :: [Partida] -> [Time]
times = sort . nub . concatMap (\p -> [mandante p, visitante p])