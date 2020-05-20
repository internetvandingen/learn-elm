port module Main exposing (..)

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as D
import Array exposing (Array)

import Uttt

-- MAIN
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- PORTS
port sendMessage : String -> Cmd msg
port messageReceiver : (String -> msg) -> Sub msg

-- MODEL
type alias Model =
      { draft : String
      , messages : List String
      , gamestate : Uttt.Gamestate
      }

init : () -> ( Model, Cmd Msg )
init flags =
    (
    { draft = ""
    , messages = []
    , gamestate = Uttt.initDemoGamestate
    }
    , Cmd.none
    )

-- UPDATE
type Msg
    = DraftChanged String
    | Send String
    | Recv String

-- Use the `sendMessage` port when someone presses ENTER or clicks
-- the "Send" button. Check out index.html to see the corresponding
-- JS where this is piped into a WebSocket.
--
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DraftChanged draft ->
            ( { model | draft = draft }
            , Cmd.none
            )

        Send message ->
            ( { model | draft = "" }
            , sendMessage message
            )

        Recv message ->
            let
                parsedMessage = parseMessage message
            in
                case parsedMessage of
                    ChatMessage content -> ( { model | messages = model.messages ++ [content] }, Cmd.none )
                    ServerMessage content -> ( { model | messages = model.messages ++ ["Server: " ++ content] }, Cmd.none )
                    UpdateGamestate gamestate -> ( { model | gamestate = gamestate }, Cmd.none )
                    --@todo: log error to console for now, but this should at least indicate to the user that something went wrong
                    Unknown error -> ( model, consoleLog error )

consoleLog str =
    let
        test = Debug.log "error" str
    in
        Cmd.none

parseMessage : String -> Protocol
parseMessage json =
    case D.decodeString (D.field "type" D.string) json of
        Ok  value ->
            if value == "ChatMessage" then
                case D.decodeString (D.field "message" D.string) json of
                    Ok content -> ChatMessage content
                    Err error -> Unknown "Error while parsing content of chat message"
            else if value == "ServerMessage" then
                case D.decodeString (D.field "message" D.string) json of
                    Ok content -> ServerMessage content
                    Err error -> Unknown "Error while parsing content of server message"
            else if value == "UpdateGamestate" then
                case D.decodeString (D.field "message" Uttt.decodeGamestate) json of
                    Ok gamestate -> UpdateGamestate gamestate
                    Err error -> Unknown <| D.errorToString error
            else
                Unknown "Unknown type of message"
        Err error -> Unknown "Could not find a type"


type Protocol
    = ChatMessage String
    | ServerMessage String
    | UpdateGamestate Uttt.Gamestate
    | Unknown String


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Recv

-- DETECT ENTER
ifIsEnter : msg -> D.Decoder msg
ifIsEnter msg =
    D.field "key" D.string
        |> D.andThen (\key -> if key == "Enter" then D.succeed msg else D.fail "some other key")


-- VIEW
view : Model -> Html.Html Msg
view model =
    Html.div []
        [ viewGame model
        , viewChat model
        ]

viewChat : Model -> Html.Html Msg
viewChat model =
    Html.div []
        [ Html.h3 [] [ Html.text "Chat" ]
        , Html.ul []
            (List.map (\msg -> Html.li [] [ Html.text msg ]) model.messages)
        , Html.input
            [ Attr.type_ "text"
            , Attr.placeholder "Draft"
            , Events.onInput DraftChanged
            , Events.on "keydown" (ifIsEnter <| Send <| Uttt.stringifyChatMessage model.draft)
            , Attr.value model.draft
            ]
            []
        , Html.button [ Events.onClick <| Send <| Uttt.stringifyChatMessage model.draft ] [ Html.text "Send" ]
        ]

viewGame : Model -> Html.Html Msg
viewGame model
    = Html.div []
        [ Html.text <| Uttt.playerToString model.gamestate.turn ++ " to make a move."
        , Html.text <| "Winner: " ++ Uttt.playerToString model.gamestate.winner
        , Html.button [ Events.onClick <| Send Uttt.stringifyUpdateRequest ] [ Html.text "Refresh" ]
        , viewBoard model.gamestate
        ]

viewBoard : Uttt.Gamestate -> Html.Html Msg
viewBoard gamestate
    = Html.div [Attr.class "board"] (List.map (\i-> viewField gamestate (i//3) (modBy 3 i)) (List.range 0 8))

viewField : Uttt.Gamestate -> Int -> Int -> Html.Html Msg
viewField gamestate row col =
    let
        field = Uttt.getField (row,col) gamestate.board
    in
        Html.div [Attr.class "field"] <| List.map (\sq -> viewSquare sq gamestate.availableMoves) (Array.toList field)

viewSquare : Uttt.Square -> Array Uttt.Pos -> Html.Html Msg
viewSquare square availableMoves =
    Html.div
    [ Attr.class "square-container", Events.onClick <| Send <| Uttt.stringifyPlaceMark square.pos ]
    [ Html.div [Attr.class "square"] [viewMark <| Uttt.playerToString square.mark]
    , Html.div [Attr.classList [ ("square", True), ("notAvailable", not <| Uttt.inArray square.pos availableMoves)]] []
    ]

viewMark : String -> Html.Html Msg
viewMark mark = Html.div [Attr.class ("marker"++mark++"1")] [Html.div [Attr.class ("marker"++mark++"2")] []]
