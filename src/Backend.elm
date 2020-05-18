port module Backend exposing (..)

import Json.Decode as D

import Uttt

main : Program () Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

port sendMessage : (String, String) -> Cmd a
port messageReceiver : (String -> a) -> Sub a

type alias Model = Uttt.Gamestate

type Msg
    = IncomingMessage String

init : () -> ( Model, Cmd Msg )
init _ = ( Uttt.initGamestate, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        IncomingMessage json -> (
            let
                parsedMessage = parseMessage json
            in
                case parsedMessage of
                    ChatMessage message -> ( model, sendMessage ("all", Uttt.stringifyChatMessage message) )
                    PlaceMark playerNumber position ->
                        let
                            result = Uttt.parsePlaceMark playerNumber position model
                        in
                            case result of
                                Ok newModel -> ( newModel, sendMessage ("all", Uttt.stringifyGamestate <| newModel) )
                                Err error -> ( model, sendMessage (String.fromInt playerNumber, Uttt.stringifyServerMessage error) )
                    --@todo: replace all by player number from error
                    Unknown error -> ( model, sendMessage ("all", Uttt.stringifyServerMessage error) )
            )

parseMessage : String -> Protocol
parseMessage json =
    case D.decodeString extractTypeAndPlayer json of
        Ok  (value, playerNumber) ->
            if value == "ChatMessage" then
                case D.decodeString (D.field "message" D.string) json of
                    Ok content -> ChatMessage content
                    Err error -> Unknown "Error while parsing content of chat message"
            else if value == "PlaceMark" then
                case D.decodeString (D.field "message" Uttt.decodePos) json of
                    Ok content -> PlaceMark playerNumber content
                    Err error -> Unknown "Error while parsing content of server message"
            else
                Unknown "Unknown type of message"
        Err error -> Unknown "Could not find a type or player number"

extractTypeAndPlayer : D.Decoder (String, Int)
extractTypeAndPlayer = D.map2 (Tuple.pair) (D.field "type" D.string) (D.field "player" D.int)

type Protocol
    = ChatMessage String
    | PlaceMark Int Uttt.Pos
    | Unknown String

subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver IncomingMessage
