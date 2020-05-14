module Ttt exposing (..)

import Json.Encode as E
import Json.Decode as D

import Array exposing (..)

------------------------------------------------------------------ TYPES

type alias Pos = (Int, Int)

type alias Square =
  { mark : Int
  , pos : Pos
  }

type alias Row = Array Square

type alias Board = Array Row

type alias Gamestate =
  { turn : Int
  , board : Board
  }

-- @todo: use custom player type instead of Int
-- Empty (0), Player 1 (X), Player 2 (O)
playerToString : Int -> String
playerToString nr =
    if nr == 1 then "X"
    else if nr == 2 then "O"
    else "_"

switchPlayer : Int -> Int
switchPlayer nr = 3-nr

------------------------------------------------------------------ DECODERS
decodeGamestate : D.Decoder Gamestate
decodeGamestate = D.map2 Gamestate (D.field "turn" D.int) (D.field "board" decodeBoard)

decodeBoard : D.Decoder Board
decodeBoard = D.array decodeRow

decodeRow : D.Decoder Row
decodeRow = D.array decodeSquare

decodeSquare : D.Decoder Square
decodeSquare = D.map2 Square (D.field "mark" D.int) (D.field "pos" decodePos)

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
encodeRow row = E.array encodeSquare row

encodeBoard : Board -> E.Value
encodeBoard board = E.array encodeRow board

encodeGamestate : Gamestate -> E.Value
encodeGamestate gamestate = E.object
    [ ("turn", E.int gamestate.turn)
    , ("board", encodeBoard gamestate.board)
    ]

--@todo: cleanup, make stringify a single function accepting different types
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

pair : Array Int -> Int -> Array Pos
pair arr fixedN =
  Array.map (\n -> (n, fixedN)) arr

range : Int -> Array Int
range max = Array.initialize max (\n -> n)

initSquare : Pos -> Square
initSquare pos =
  { mark = 0
  , pos = pos
  }

initGamestate : Gamestate
initGamestate =
  { turn = 1
  , board = initBoard
  }

initBoard : Board
initBoard = Array.map initRow (range 3 )

initRow : Int -> Array Square
initRow rowNr = Array.map initSquare (pair (range 3) rowNr)


------------------------------------------------------------------ GAMELOGIC

parsePlaceMark : Int -> Pos -> Gamestate -> Result String Gamestate
parsePlaceMark playerN (colN, rowN) gamestate =
    if gamestate.turn == playerN then
            case Array.get rowN gamestate.board of
                Nothing -> Err "rowN out of range"
                Just row -> case Array.get colN row of
                    Nothing -> Err "colN out of range"
                    Just square ->
                        if square.mark /= 0 then
                            Err "square is already occupied"
                        else
                            let
                                newstate = {gamestate | turn = switchPlayer gamestate.turn}
                            in
                                Ok { newstate | board = Array.set rowN (Array.set colN {mark=playerN,pos=(colN,rowN)} row) newstate.board }

    else
        Err "not your turn"