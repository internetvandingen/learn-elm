port module Main exposing (..)

import Browser
import Html
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as D

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
  }

init : () -> ( Model, Cmd Msg )
init flags =
  ( { draft = "", messages = [] }
  , Cmd.none
  )

-- UPDATE
type Msg
  = DraftChanged String
  | Send
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

    Send ->
      ( { model | draft = "" }
      , sendMessage model.draft
      )

    Recv message ->
      ( { model | messages = model.messages ++ [message] }
      , Cmd.none
      )

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
  messageReceiver Recv


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
        , Events.on "keydown" (ifIsEnter Send)
        , Attr.value model.draft
        ]
        []
    , Html.button [ Events.onClick Send ] [ Html.text "Send" ]
    ]

viewGame : Model -> Html.Html Msg
viewGame model = Html.text "test"

-- DETECT ENTER
ifIsEnter : msg -> D.Decoder msg
ifIsEnter msg =
  D.field "key" D.string
    |> D.andThen (\key -> if key == "Enter" then D.succeed msg else D.fail "some other key")
