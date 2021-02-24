module Mob.Tabs.Home exposing (..)

import Html exposing (Html, a, button, div, i, span, strong, text)
import Html.Attributes exposing (class, href, id, title)
import Html.Events exposing (onClick)
import Out.Commands
import Url


type Msg
    = PutLinkInPasteBin Url.Url


update : Msg -> Cmd Msg
update msg =
    case msg of
        PutLinkInPasteBin url ->
            Url.toString url
                |> Out.Commands.CopyInPasteBin
                |> Out.Commands.send


view : String -> Url.Url -> Html Msg
view mobName url =
    div
        [ id "home", class "tab" ]
        [ shareButton mobName url
        , a
            [ href "https://github.com/HadrienMP/mob-time-elm"
            , id "git"
            ]
            [ i [ class "fab fa-github" ] []
            , text "Fork me on github!"
            ]
        ]


shareButton : String -> Url.Url -> Html Msg
shareButton mob url =
    button
        [ onClick <| PutLinkInPasteBin url
        , id "share-link"
        , title "Copy this mob's link in your clipboard"
        ]
        [ shareText mob
        , i [ id "share-button", class "fas fa-share-alt" ] []
        ]


shareText : String -> Html Msg
shareText mob =
    span []
        [ text "You are in the "
        , strong [] [ text mob ]
        , text " mob"
        ]
