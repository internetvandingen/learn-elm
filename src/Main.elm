module Main exposing (..)

import Browser
import Html exposing (Html, button, div, input, text, select, option, label)
import Html.Events exposing (onClick, onInput, onCheck)
import Html.Attributes exposing (placeholder, value, type_)


-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL

type alias Model =
  { count : Int
  , textField : String
  , checked : Bool
  }


init : Model
init =
  Model 0 "" False



-- UPDATE


type Msg
  = Increment
  | Decrement
  | Change String
  | Toggle Bool


boolToString : Bool -> String
boolToString checked =
  if checked then
    "Checked"
  else
    "Unchecked"

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      { count = model.count + 1
      , textField = model.textField
      , checked = model.checked
      }

    Decrement ->
      { count = model.count - 1
      , textField = model.textField
      , checked = model.checked
      }

    Change text ->
      { count = model.count + String.length text - String.length model.textField
      , textField = text
      , checked = model.checked
      }

    Toggle checked ->
      { count = model.count
      , textField = model.textField
      , checked = not model.checked
      }



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [
    div []
      [ button [ onClick Decrement ] [ text "-" ]
      , div [] [ text (String.fromInt model.count) ]
      , button [ onClick Increment ] [ text "+" ]
      ]
    , input [ placeholder "Text", value model.textField, onInput Change ] [ ]
    , select [ onInput Change ]
      [ option [ value "One" ] [ text "1"]
      , option [ value "Two" ] [ text "2"]
      , option [ value "Three" ] [ text "3"]
      ]
    , label []
      [ text "Example checkbox"
      , input [ type_ "checkbox", onCheck Toggle ] [ ]
      ]
    , div [] [ text (String.fromInt model.count ++ " " ++ model.textField ++ " " ++ boolToString model.checked) ]
    ]