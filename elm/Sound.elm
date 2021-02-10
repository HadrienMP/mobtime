port module Sound exposing (..)

import Json.Encode


port externalCommands : Json.Encode.Value -> Cmd msg


play : Cmd msg
play =
    externalCommands <|
        Json.Encode.object
            [ ( "name", Json.Encode.string "play" )
            , ( "data", Json.Encode.object [] )
            ]


stop : Cmd msg
stop =
    externalCommands <|
        Json.Encode.object
            [ ( "name", Json.Encode.string "stop" )
            , ( "data", Json.Encode.object [] )
            ]
