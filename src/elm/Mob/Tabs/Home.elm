module Mob.Tabs.Home exposing (..)

import Footer
import Html exposing (Html, a, button, dd, div, dl, dt, i, li, span, strong, text, ul)
import Html.Attributes exposing (class, href, id, target, title)
import Html.Events exposing (onClick)
import Mob.Tabs.Mobbers as Mobbers
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


view : String -> Url.Url -> Mobbers.Model -> Html Msg
view mobName url mobbers =
    div
        [ id "home", class "tab" ]
        [ shareButton mobName url
        , roles mobbers
        , Footer.view
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


roles : Mobbers.Model -> Html msg
roles mobbers =
    Mobbers.mobberRoles mobbers
        |> List.filter Mobbers.specificRole
        |> List.map roleView
        |> (\list ->
                case list of
                    [] ->
                        div [] []

                    _ ->
                        ul [ class "mobber-roles" ] list
           )


roleView : Mobbers.MobberRole -> Html msg
roleView mobberRole =
    li [ class "mobber-role" ]
        [ span [ class "role" ] [ text mobberRole.role ]
        , span [ class "mobber" ] [ text mobberRole.name ]
        ]
