-- Camada 2: ordem superior

module Classificacao where

import Data.List (sortBy)
import Data.Maybe (listToMaybe)
import Data.Ord (Down (..), comparing)
import Tipos

pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

golsDoTime :: Time -> Partida -> (Int, Int)
golsDoTime t p
  | t == mandante p = (golsMandante p, golsVisitante p)
  | otherwise       = (golsVisitante p, golsMandante p)

conta :: Resultado -> Resultado -> Int
conta alvo r = if alvo == r then 1 else 0

somar :: Linha -> (Int, Int) -> Resultado -> Linha
somar l (pro, contra) r = l
  { jogos      = jogos l + 1
  , vitorias   = vitorias l + conta Vitoria r
  , empates    = empates l + conta Empate r
  , derrotas   = derrotas l + conta Derrota r
  , golsPro    = golsPro l + pro
  , golsContra = golsContra l + contra
  }

acumular :: Time -> Linha -> Partida -> Linha
acumular t l p = maybe l (somar l (golsDoTime t p)) (resultadoPara t p)

linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldl (acumular t) (Linha t 0 0 0 0 0 0) (filter (participou t) ps)

pontosLinha :: Linha -> Int
pontosLinha l = 3 * vitorias l + empates l

saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise    = 100 * fromIntegral (pontosLinha l) / fromIntegral (3 * jogos l)

criterio :: Linha -> Linha -> Ordering
criterio = comparing (Down . pontosLinha)
        <> comparing (Down . vitorias)
        <> comparing (Down . saldo)
        <> comparing (Down . golsPro)
        <> comparing time

classificacao :: [Partida] -> [Linha]
classificacao ps = sortBy criterio (map (linhaDoTime ps) (times ps))

ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n = filter ((<= n) . rodada)

diferenca :: Partida -> Int
diferenca p = abs (golsMandante p - golsVisitante p)

maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada = listToMaybe . sortBy (comparing (Down . diferenca))

mediaGols :: [Partida] -> Maybe Double
mediaGols ps
  | null ps   = Nothing
  | otherwise = Just (fromIntegral total / fromIntegral (length ps))
  where total = sum (map (\p -> golsMandante p + golsVisitante p) ps)