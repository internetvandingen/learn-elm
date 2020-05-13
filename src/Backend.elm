port module Backend exposing (..)

import Ttt

main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

port sendMessage : String -> Cmd a
port messageReceiver : (String -> a) -> Sub a

type alias Model = Ttt.Gamestate

type Msg
    = IncomingMessage String

init : () -> ( Model, Cmd Msg )
init _ = ( Ttt.initGamestate, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncomingMessage string -> (
            let
                newModel = model
            in
                ( newModel, sendMessage <| Ttt.stringifyGamestate newModel ))

subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver IncomingMessage
