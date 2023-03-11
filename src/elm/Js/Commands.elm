port module Js.Commands exposing (Command(..), OutCommand, send)

import Json.Encode as Json


port commands : OutCommand -> Cmd msg


type Command
    = ChangeTitle String


type alias OutCommand =
    { name : String
    , value : Json.Value
    }


send : Command -> Cmd msg
send command =
    commands <|
        case command of
            ChangeTitle title ->
                OutCommand "ChangeTitle" <| Json.string title
