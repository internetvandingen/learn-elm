module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "Game logic"
        [ test "dummy test" <|
            \_ -> Expect.equal 1 1
        ]
