module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Uttt

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
        ]
