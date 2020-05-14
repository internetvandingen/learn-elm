port module Main exposing (..)

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as D
import Array exposing (Array)

import Ttt

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
  , gamestate : Ttt.Gamestate
  }

init : () -> ( Model, Cmd Msg )
init flags =
  (
    { draft = ""
    , messages = []
    , gamestate = Ttt.initGamestate
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
          UpdateGamestate gamestate -> ( { model | gamestate = gamestate }, Cmd.none )
          Unknown error -> ( model, Cmd.none )

parseMessage : String -> Protocol
parseMessage json =
    case D.decodeString (D.field "type" D.string) json of
        Ok  value ->
            if value == "ChatMessage" then
              case D.decodeString (D.field "message" D.string) json of
                Ok content -> ChatMessage content
                Err error -> Unknown "Error while parsing content of chat message"
            else if value == "UpdateGamestate" then
              case D.decodeString (D.field "message" Ttt.decodeGamestate) json of
                Ok gamestate -> UpdateGamestate gamestate
                Err error -> Unknown "Error while parsing new gamestate"
            else
                Unknown "Unknown type of message"
        Err error -> Unknown "Could not find a type"


type Protocol
    = ChatMessage String
    | UpdateGamestate Ttt.Gamestate
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
    [ Html.h2 [] [ Html.text "Echo Chat" ]
    , Html.ul []
        (List.map (\msg -> Html.li [] [ Html.text msg ]) model.messages)
    , Html.input
        [ Attr.type_ "text"
        , Attr.placeholder "Draft"
        , Events.onInput DraftChanged
        , Events.on "keydown" (ifIsEnter <| Send <| Ttt.stringifyChatMessage model.draft)
        , Attr.value model.draft
        ]
        []
    , Html.button [ Events.onClick <| Send <| Ttt.stringifyChatMessage model.draft ] [ Html.text "Send" ]
    ]

viewGame : Model -> Html.Html Msg
viewGame model
  = Html.table [] (List.map viewRow (Array.toList model.gamestate.board))


viewRow : Ttt.Row -> Html.Html Msg
viewRow row
  = Html.tr [] (List.map viewSquare (Array.toList row))

viewSquare : Ttt.Square -> Html.Html Msg
viewSquare square =
  let
    customStyle = Attr.style "border" "1px solid black"
  in
    Html.td [ customStyle, Events.onClick <| Send <| Ttt.encodePlaceMark square.pos ] [ Html.text <| Ttt.playerToString square.mark ]
