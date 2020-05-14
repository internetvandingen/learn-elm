port module Backend exposing (..)

import Json.Decode as D

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
        IncomingMessage json -> (
            let
                parsedMessage = parseMessage json
            in
                case parsedMessage of
                    ChatMessage message -> ( model, sendMessage <| Ttt.stringifyChatMessage message )
                    PlaceMark position ->
                        let
                            newModel = Ttt.parsePlaceMark position model
                        in
                            ( newModel, sendMessage <| Ttt.stringifyGamestate <| newModel )
                    -- @todo: don't send a chat message on error, but servermessage
                    Unknown error -> ( model, sendMessage <| Ttt.stringifyChatMessage error )
            )

parseMessage : String -> Protocol
parseMessage json =
    case D.decodeString (D.field "type" D.string) json of
        Ok  value ->
            if value == "ChatMessage" then
                case D.decodeString (D.field "message" D.string) json of
                    Ok content -> ChatMessage content
                    Err error -> Unknown "Error while parsing content of chat message"
            else if value == "PlaceMark" then
                case D.decodeString (D.field "message" Ttt.decodePos) json of
                    Ok content -> PlaceMark content
                    Err error -> Unknown "Error while parsing position of PlaceMark"
            else
                Unknown "Unknown type of message"
        Err error -> Unknown "Could not find a type"


type Protocol
    = ChatMessage String
    | PlaceMark Ttt.Pos
    | Unknown String


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver IncomingMessage
