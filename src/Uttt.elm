module Uttt exposing (..)

import Json.Encode as E
import Json.Decode as D

import Array exposing (..)

------------------------------------------------------------------ TYPES

-- @todo: use custom player type instead of Int
-- Empty (0), Player 1 (X), Player 2 (O)
playerToString : Int -> String
playerToString nr =
    if nr == 1 then "X"
    else if nr == 2 then "O"
    else "_"

switchPlayer : Int -> Int
switchPlayer nr = 3-nr

-- (row, col)
type alias Pos = (Int, Int)

type alias Square =
    { mark : Int
    , pos : Pos
    }

type alias Board = Array Square

type alias Gamestate =
    { turn : Int
    , board : Board
    }


------------------------------------------------------------------ HELPERS

--pair : Array Int -> Int -> Array Pos
--pair arr fixedN =
--  Array.map (\n -> (n, fixedN)) arr

range : Int -> Array Int
range max = Array.initialize max (\n -> n)

indexToPos : Int -> Pos
indexToPos i = (i//9, modBy 9 i)

posToIndex : Pos -> Int
posToIndex pos = (Tuple.first pos)*9 + (Tuple.second pos)

getRow : Int -> Board -> Array Square
getRow rowN board = Array.slice (rowN*9) ((rowN+1)*9) board

------------------------------------------------------------------ INITIALIZE

initSquare : Pos -> Square
initSquare pos =
    { mark = 0
    , pos = pos
    }

initBoard : Board
initBoard = Array.map (\index -> initSquare <| indexToPos index ) (range 81 )

initGamestate : Gamestate
initGamestate =
    { turn = 1
    , board = initBoard
    }


------------------------------------------------------------------ GAMELOGIC

parsePlaceMark : Int -> Pos -> Gamestate -> Result String Gamestate
parsePlaceMark playerN pos gamestate =
    if gamestate.turn == playerN then
        case Array.get (posToIndex pos) gamestate.board of
            Nothing -> Err "Invalid move, invalid square selected"
            Just square ->
                if square.mark /= 0 then
                    Err "Invalid move, square is already occupied"
                    else
                        let
                            newstate = {gamestate | turn = switchPlayer gamestate.turn}
                        in
                            Ok { newstate | board = Array.set (posToIndex pos) {mark=playerN,pos=pos} newstate.board }
    else
        Err "Not your turn"


------------------------------------------------------------------ DECODERS

decodeGamestate : D.Decoder Gamestate
decodeGamestate = D.map2 Gamestate (D.field "turn" D.int) (D.field "board" decodeBoard)

decodeBoard : D.Decoder Board
decodeBoard = D.array decodeSquare

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

encodeBoard : Board -> E.Value
encodeBoard board = E.array encodeSquare board

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
