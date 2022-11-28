module Lib.Konami exposing
    ( Konami
    , Msg(..)
    , init
    , isOn
    , subscriptions
    , update
    )

import Browser.Events exposing (onKeyUp)
import Json.Decode
import Lib.Keyboard


type Konami
    = Off (List String)
    | On


isOn : Konami -> Bool
isOn konami =
    case konami of
        On ->
            True

        _ ->
            False


konamiSequence : List String
konamiSequence =
    List.reverse
        [ "ArrowUp"
        , "ArrowUp"
        , "ArrowDown"
        , "ArrowDown"
        , "ArrowLeft"
        , "ArrowRight"
        , "ArrowLeft"
        , "ArrowRight"
        , "a"
        , "b"
        ]



-- Init


init : Konami
init =
    Off []



-- Update


type Msg
    = KeyPressed Lib.Keyboard.Keystroke


update : Msg -> Konami -> ( Konami, Cmd Msg )
update msg model =
    case model of
        Off keys ->
            case msg of
                KeyPressed { key } ->
                    let
                        updated =
                            key :: keys |> List.take (List.length konamiSequence)
                    in
                    ( if updated == konamiSequence then
                        On

                      else
                        Off updated
                    , Cmd.none
                    )

        On ->
            ( On, Cmd.none )



-- Subscriptions


subscriptions : Konami -> Sub Msg
subscriptions _ =
    onKeyUp <|
        Json.Decode.map KeyPressed <|
            Lib.Keyboard.decode
