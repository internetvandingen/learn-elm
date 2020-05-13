port module Backend exposing (..)

main : Program () Model Msg
main =
    nodeProgram (print "test")

nodeProgram : a -> Program () Model Msg
nodeProgram _ =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }

port sendMessage : String -> Cmd a
port messageReceiver : (String -> a) -> Sub a

type alias Model = String
type Msg
    = Send String
    | Recv String

init : () -> ( Model, Cmd Msg )
init _ = ( "init", Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Send string -> ( model, sendMessage string )
        Recv string -> ( print string, Cmd.none )

print : Model -> Model
print str =
    Debug.log str str


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver Send