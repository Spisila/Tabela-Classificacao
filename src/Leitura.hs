-- Camada 3: Maybe, Either e formatacao

data Erro
  = CamposInvalidos String
  | NumeroInvalido String
  | PlacarNegativo String
  | MesmoTime String
  | TimeRepetidoNaRodada Int Time

separar :: Char -> String -> [String]

lerPartida :: Int -> String -> Either Erro Partida

lerCampeonato :: String -> Either Erro [Partida]

todosOsErros :: String -> [Erro]

tabelaFormatada :: [Linha] -> String