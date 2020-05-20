module UtttTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Uttt

import Array
import Json.Decode as D

suite : Test
suite =
    describe "Exposed functions of Uttt module"
        [ describe "Encoders"
            [ test "stringifyPlaceMark" <|
                \_ -> Uttt.stringifyPlaceMark (1,2) |> Expect.equal "{\"type\":\"PlaceMark\",\"message\":[1,2]}"
            , test "stringifyUpdateRequest" <|
                \_ -> Uttt.stringifyUpdateRequest |> Expect.equal "{\"type\":\"UpdateRequest\",\"message\":\"\"}"
            , test "stringifyServerMessage" <|
                \_ -> Uttt.stringifyServerMessage "test" |> Expect.equal "{\"type\":\"ServerMessage\",\"message\":\"test\"}"
            , test "stringifyChatMessage" <|
                \_ -> Uttt.stringifyChatMessage "chat message" |> Expect.equal "{\"type\":\"ChatMessage\",\"message\":\"chat message\"}"
            ]
            --@todo: write encoder and decoder tests for gamestate. Currently too large to paste into here
            -- Maybe I can encode and decode in the same test and expect the same result, for now don't test it
        , describe "Decoders"
            [ test "decodePos" <|
                \_ -> D.decodeString Uttt.decodePos "[1,2]" |> Expect.equal (Ok (1,2))
            ]
        , describe "initGamestate"
            [ test "winner" <|
                \_ -> Uttt.initGamestate.winner |> Expect.equal 0
            , test "turn" <|
                \_ -> Uttt.initGamestate.turn |> Expect.equal 1
            , test "available moves" <|
                \_ -> Array.length Uttt.initGamestate.availableMoves |> Expect.equal 81
            , test "board mark" <|
                \_ -> Array.foldl (\square sum -> sum+square.mark) 0 Uttt.initGamestate.board |> Expect.equal 0
            , test "board length" <|
                \_ -> Array.length Uttt.initGamestate.board |> Expect.equal 81
            ]
        , describe "inArray"
            [ test "in array" <|
                \_ -> Uttt.inArray (1,2) (Array.fromList [(2,1), (1,2), (0,0)]) |> Expect.true "Element is in array, but got false"
            , test "not in array" <|
                \_ -> Uttt.inArray (1,2) (Array.fromList [(2,1), (0,0)]) |> Expect.false "Element is not in array, but got true"
            ]
        , describe "parsePlaceMark"
            [ test "valid move 1" <|
                \_ -> Uttt.parsePlaceMark 1 (8,8) Uttt.initGamestate |> Expect.ok
            , test "valid move 2" <|
                \_ ->
                    let
                        setup = Uttt.parsePlaceMark 1 (8,8) Uttt.initGamestate
                    in
                        case setup of
                            Err _ -> Expect.fail "Something went wrong while setting up for this test"
                            Ok gamestateFirstMove ->
                                if (8 == Array.length gamestateFirstMove.availableMoves) then
                                    case Uttt.parsePlaceMark 2 (7,7) gamestateFirstMove of
                                        Err _ -> Expect.fail "Placing a valid move produced an error"
                                        Ok gamestateSecondMove -> Expect.true "Gamestate is invalid"
                                            (  (9 == Array.length gamestateSecondMove.availableMoves)
                                            && (1 == Array.length (Array.filter (\sq -> sq.mark == 1) gamestateSecondMove.board) )
                                            && (1 == Array.length (Array.filter (\sq -> sq.mark == 2) gamestateSecondMove.board) )
                                            )
                                else
                                    Expect.fail "wrong number of available moves after move 1"

            , test "not your turn" <|
                \_ -> Uttt.parsePlaceMark 2 (0,0) Uttt.initGamestate |> Expect.equal (Err "Not your turn")
            , test "invalid move" <|
                \_ ->
                    let
                        setup = Uttt.parsePlaceMark 1 (8,8) Uttt.initGamestate
                    in
                        case setup of
                            Ok validGamestate -> Uttt.parsePlaceMark 2 (8,8) validGamestate |> Expect.equal (Err "Invalid move")
                            Err _ -> Expect.fail "Something went wrong while setting up for this test"
            , test "invalid square selected" <|
                \_ -> Uttt.parsePlaceMark 1 (9,0) Uttt.initGamestate |> Expect.equal (Err "Invalid move")
            ]
        ]
