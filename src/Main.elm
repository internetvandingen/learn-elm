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
  , gamestate : Gamestate
  }

init : () -> ( Model, Cmd Msg )
init flags =
  (
    { draft = ""
    , messages = []
    , gamestate = initGamestate
    }
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
        , Events.on "keydown" (ifIsEnter Send)
        , Attr.value model.draft
        ]
        []
    , Html.button [ Events.onClick Send ] [ Html.text "Send" ]
    ]

viewGame : Model -> Html.Html Msg
viewGame model
  = Html.table [] (List.map viewRow model.gamestate.squares)


viewRow : Row -> Html.Html Msg
viewRow row
  = Html.tr [ Events.onClick <| Recv <| String.fromInt 0 ] (List.map viewSquare row)

viewSquare : Square -> Html.Html Msg
viewSquare square
  = Html.td [ Attr.style "border" "1px solid black" ] [ Html.text <| (String.fromInt <| Tuple.first square.pos) ++ ", " ++ (String.fromInt <| Tuple.second square.pos) ]

-- Game
initGamestate : Gamestate
initGamestate =
  { turn = 1
  , squares = initBoard
  }

initBoard : Board
initBoard = List.map initRow (List.range 0 2)

initRow : Int -> List Square
initRow rowNr = List.map initSquare (pairs (List.repeat 3 rowNr) (List.range 0 2))

initSquare : Pos -> Square
initSquare pos =
  { mark = 0
  , pos = ( Tuple.first pos, Tuple.second pos )
  }

type alias Gamestate =
  { turn : Int
  , squares : Board
  }

type alias Board = List Row

type alias Row = List Square

type alias Square =
  { mark : Int
  , pos : Pos
  }

type alias Pos = (Int, Int)

pairs : List a -> List b -> List (a,b)
pairs xs ys =
  List.map2 Tuple.pair xs ys
