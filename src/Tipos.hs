-- Camada 1: tipos e consultas basicas

module Tipos where 

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

-- participou :: Time -> Partida -> Bool

-- resultadoPara :: Time -> Partida -> Maybe Resultado

-- times :: [Partida] -> [Time]