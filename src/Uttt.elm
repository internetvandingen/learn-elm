module Uttt exposing (
      Gamestate
    , Square
    , Pos
    , initGamestate
    , stringifyGamestate
    , stringifyChatMessage
    , stringifyServerMessage
    , stringifyUpdateRequest
    , parsePlaceMark
    , playerToString
    , getRow
    , isMoveAvailable
    , encodePlaceMark
    , decodeGamestate
    , decodePos)

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
    else ""

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
    , availableMoves : Array Pos
    , winner : Int
    }


------------------------------------------------------------------ HELPERS

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
initBoard = Array.map (\index -> initSquare <| indexToPos index) (range 81)

initGamestate : Gamestate
initGamestate =
    { turn = 1
    , board = initBoard
    , availableMoves = Array.map (\index -> indexToPos index) (range 81)
    , winner = 0
    }


------------------------------------------------------------------ GAMELOGIC

parsePlaceMark : Int -> Pos -> Gamestate -> Result String Gamestate
parsePlaceMark playerN pos gamestate =
    if gamestate.winner /= 0 then
        Err "Game is over"
    else if gamestate.turn /= playerN then
        Err "Not your turn"
    else
        case Array.get (posToIndex pos) gamestate.board of
            Nothing -> Err "Invalid move, square not on board"
            Just square ->
                if isMoveAvailable pos gamestate.availableMoves then
                    let
                        newBoard = Array.set (posToIndex pos) {mark=playerN,pos=pos} gamestate.board

                        winner = getWinner newBoard
                    in
                        Ok  { gamestate
                            | board = newBoard
                            , turn = switchPlayer gamestate.turn
                            , availableMoves = getAvailableMoves pos newBoard
                            , winner = Debug.log "winner" winner
                            }
                else
                    Err "Invalid move"

getWinner : Board -> Int
getWinner board = getWinnerField <| constructSuper board

constructSuper : Board -> Array Square
constructSuper board = Array.map (\i-> {mark=getWinnerField <| getField (i//3, modBy 3 i) board, pos = (i//3, modBy 3 i)}) (range 9)

getWinnerField : Array Square -> Int
getWinnerField field =
    let
        row = getWinnerRow field
        col = getWinnerCol field
        diag = getWinnerDiagonal field
    in
        if row /= 0 then
            row
        else if col /= 0 then
            col
        else
            diag


getWinnerDiagonal : Array Square -> Int
getWinnerDiagonal field =
    let
        diag1 = getWinnerArray (Array.slice 0 1 field |> Array.append (Array.slice 4 5 field) |> Array.append (Array.slice 8 9 field))
        diag2 = getWinnerArray (Array.slice 2 3 field |> Array.append (Array.slice 4 5 field) |> Array.append (Array.slice 6 7 field))
    in
        if diag1 /= 0 then
            diag1
        else
            diag2

getWinnerCol : Array Square -> Int
getWinnerCol field =
    let
        col1 = getWinnerArray <| getColumn 0 field
        col2 = getWinnerArray <| getColumn 1 field
    in
        if col1 /= 0 then
            col1
        else if col2 /= 0 then
            col2
        else
            getWinnerArray <| getColumn 2 field

getColumn : Int -> Array Square -> Array Square
getColumn col field =
    Array.slice col (col+1) field |> Array.append (Array.slice (col+3) (col+4) field) |> Array.append (Array.slice (col+6) (col+7) field)


getWinnerRow : Array Square -> Int
getWinnerRow field =
    let
        row1 = getWinnerArray <| Array.slice 0 3 field

        row2 = getWinnerArray <| Array.slice 3 6 field
    in
        if row1 /= 0 then
            row1
        else if row2 /= 0 then
            row2
        else
            getWinnerArray <| Array.slice 6 9 field

getWinnerArray : Array Square -> Int
getWinnerArray arr =
    if 3 == (Array.length <| Array.filter (\sq-> sq.mark == 1) arr) then
        1
    else if 3 == (Array.length <| Array.filter (\sq-> sq.mark == 2) arr) then
        2
    else
        0

isMoveAvailable : Pos -> Array Pos -> Bool
isMoveAvailable pos moves =
    1 == Array.length (Array.filter (\move -> move == pos) moves)

getAvailableMoves : Pos -> Board -> Array Pos
getAvailableMoves lastMove board =
    let
        fieldPos = ( modBy 3 <| Tuple.first lastMove, modBy 3 <| Tuple.second lastMove )
    in
        Array.map (\square -> square.pos)
            <| Array.filter (\square -> square.mark == 0) (getField fieldPos board)

getField : (Int, Int) -> Board -> Array Square
getField (row, col) board =
    let
        fieldStartingIndex = posToIndex (3*row, 3*col)
    in
        (Array.slice (fieldStartingIndex+18) (fieldStartingIndex+21) board)
        |> Array.append (Array.slice (fieldStartingIndex+9) (fieldStartingIndex+12) board)
        |> Array.append (Array.slice fieldStartingIndex (fieldStartingIndex+3) board)

------------------------------------------------------------------ DECODERS

decodeGamestate : D.Decoder Gamestate
decodeGamestate
    = D.map4 Gamestate
        (D.field "turn" D.int)
        (D.field "board" <| D.array decodeSquare)
        (D.field "availableMoves" <| D.array decodePos)
        (D.field "winner" D.int)

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
    , ("availableMoves", E.array encodePos gamestate.availableMoves)
    , ("winner", E.int gamestate.winner)
    ]

--@todo: cleanup, make stringify a single function accepting different types
stringifyGamestate : Gamestate -> String
stringifyGamestate gamestate = encodeSendMessage "UpdateGamestate" <| encodeGamestate gamestate

stringifyChatMessage : String -> String
stringifyChatMessage messageContent = encodeSendMessage "ChatMessage" <| E.string messageContent

stringifyServerMessage : String -> String
stringifyServerMessage messageContent = encodeSendMessage "ServerMessage" <| E.string messageContent

stringifyUpdateRequest : String
stringifyUpdateRequest = encodeSendMessage "UpdateRequest" <| E.string ""

encodeSendMessage : String -> E.Value -> String
encodeSendMessage msgType message =
    let
        encodedMessage = E.object
            [ ("type", E.string msgType)
            , ("message", message)
            ]
    in
        E.encode 0 encodedMessage
