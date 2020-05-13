module Ttt exposing (..)

import Json.Encode as E



type alias Pos = (Int, Int)

type alias Square =
  { mark : Int
  , pos : Pos
  }

type alias Row = List Square

type alias Board = List Row

type alias Gamestate =
  { turn : Int
  , squares : Board
  }

encodePos : Pos -> String
encodePos pos = E.encode 0 (E.list E.int [Tuple.first pos, Tuple.second pos])

pairs : List a -> List b -> List (a,b)
pairs xs ys =
  List.map2 Tuple.pair xs ys

initSquare : Pos -> Square
initSquare pos =
  { mark = 0
  , pos = ( Tuple.first pos, Tuple.second pos )
  }

initGamestate : Gamestate
initGamestate =
  { turn = 1
  , squares = initBoard
  }

initBoard : Board
initBoard = List.map initRow (List.range 0 2)

initRow : Int -> List Square
initRow rowNr = List.map initSquare (pairs (List.repeat 3 rowNr) (List.range 0 2))
