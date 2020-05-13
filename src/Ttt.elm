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

encodePlaceMark : Pos -> String
encodePlaceMark pos =
    let
        encodedPos = E.object
            [ ("type", E.string "PlaceMark")
            , ("message", encodePos pos)
            ]
    in
        E.encode 0 encodedPos

encodePos : Pos -> E.Value
encodePos pos = E.list E.int [Tuple.first pos, Tuple.second pos]

encodeSendChatMessage : String -> String
encodeSendChatMessage message =
    let
        encodedMessage = E.object
            [ ("type", E.string "ChatMessage")
            , ("message", E.string message)
            ]
    in
        E.encode 0 encodedMessage


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
