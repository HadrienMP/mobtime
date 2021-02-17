module Mob.Tabs.Dev exposing (..)

import Html exposing (Html, button, div, i, label, text)
import Html.Attributes exposing (class, classList, for, id)
import Html.Events exposing (onClick)
import Mob.Lib.Duration as Duration exposing (Duration)


type Speed
    = Normal
    | Fast


type alias Model =
    { speed : Speed }


init : Model
init =
    { speed = Normal }


type Msg
    = SpeedChanged Speed


seconds : Model -> Duration
seconds model =
    case model.speed of
        Normal -> Duration.ofSeconds 1
        Fast -> Duration.ofSeconds 20

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SpeedChanged speed ->
            ( { model | speed = speed }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ id "dev", class "tab" ]
        [ div
            [ id "speed-field", class "form-field" ]
            [ label [ for "speed" ] [ text "Speed" ]
            , div
                [ class "toggles" ]
                [ button
                    [ classList [ ( "active", model.speed == Normal ) ]
                    , onClick <| SpeedChanged Normal
                    ]
                    [ i [ class "fas fa-angle-right" ] []
                    , text " | Normal"
                    ]
                , button
                    [ classList [ ( "active", model.speed == Fast ) ]
                    , onClick <| SpeedChanged Fast
                    ]
                    [ i [ class "fas fa-angle-double-right" ] []
                    , text " | Fast"
                    ]
                ]
            ]
        ]
