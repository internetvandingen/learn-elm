module Ttt exposing (..)

import Json.Encode as E
import Json.Decode as D


------------------------------------------------------------------ TYPES

type alias Pos = (Int, Int)

type alias Square =
  { mark : Int
  , pos : Pos
  }

type alias Row = List Square

type alias Board = List Row

type alias Gamestate =
  { turn : Int
  , board : Board
  }

decodePos : D.Decoder Pos
decodePos = D.map2 (Tuple.pair) (D.index 0 D.int) (D.index 1 D.int)

------------------------------------------------------------------ ENCODERS
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

encodeSquare : Square -> E.Value
encodeSquare square = E.object
    [ ("mark", E.int square.mark)
    , ("pos", encodePos square.pos)
    ]

encodeRow : Row -> E.Value
encodeRow row = E.list encodeSquare row

encodeBoard : Board -> E.Value
encodeBoard board = E.list encodeRow board

encodeGamestate : Gamestate -> E.Value
encodeGamestate gamestate = E.object
    [ ("turn", E.int gamestate.turn)
    , ("board", encodeBoard gamestate.board)
    ]

stringifyGamestate : Gamestate -> String
stringifyGamestate gamestate = encodeSendMessage "UpdateGamestate" <| encodeGamestate gamestate

stringifyChatMessage : String -> String
stringifyChatMessage messageContent = encodeSendMessage "ChatMessage" <| E.string messageContent

stringifyServerMessage : String -> String
stringifyServerMessage messageContent = encodeSendMessage "ServerMessage" <| E.string messageContent

encodeSendMessage : String -> E.Value -> String
encodeSendMessage msgType message =
    let
        encodedMessage = E.object
            [ ("type", E.string msgType)
            , ("message", message)
            ]
    in
        E.encode 0 encodedMessage

------------------------------------------------------------------ INITIALIZE

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
  , board = initBoard
  }

initBoard : Board
initBoard = List.map initRow (List.range 0 2)

initRow : Int -> List Square
initRow rowNr = List.map initSquare (pairs (List.repeat 3 rowNr) (List.range 0 2))
