-- Camada 2: ordem superior

module Classificacao where

import Tipos

pontos :: Resultado -> Int

linhaDoTime :: [Partida] -> Time -> Linha

pontosLinha :: Linha -> Int

saldo :: Linha -> Int

aproveitamento :: Linha -> Double

classificacao :: [Partida] -> [Linha]

ateRodada :: Int -> [Partida] -> [Partida]

maiorGoleada :: [Partida] -> Maybe Partida

mediaGols :: [Partida] -> Maybe Double