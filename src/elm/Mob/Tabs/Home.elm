module Mob.Tabs.Home exposing (..)

import Footer
import Html exposing (Html, button, div, i, li, span, strong, text, ul)
import Html.Attributes exposing (class, id, title)
import Html.Events exposing (onClick)
import Js.Commands
import Lib.Icons
import Mobbers.Model exposing (Mobber, Mobbers)
import Mobbers.Settings
import Url


type Msg
    = PutLinkInPasteBin Url.Url


update : Msg -> Cmd Msg
update msg =
    case msg of
        PutLinkInPasteBin url ->
            Url.toString url
                |> Js.Commands.CopyInPasteBin
                |> Js.Commands.send


view : String -> Url.Url -> Mobbers -> Html Msg
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
        , Lib.Icons.share
        ]


shareText : String -> Html Msg
shareText mob =
    span []
        [ text "You are in the "
        , strong [] [ text mob ]
        , text " mob"
        ]


roles : Mobbers -> Html msg
roles mobbers =
    Mobbers.Settings.assignRoles mobbers
        |> List.filter (\(_, mobber) -> mobber /= Nothing)
        |> List.take 2
        |> List.map roleView
        |> (\list ->
                case list of
                    [] ->
                        div [] []

                    _ ->
                        ul [ class "mobber-roles" ] list
           )


roleView : ( Maybe String, Maybe Mobber ) -> Html msg
roleView (role, mobber) =
    li [ class "mobber-role" ]
        [ span [ class "role" ] [ role |> Maybe.withDefault "Wut ?" |> text ]
        , span [ class "mobber" ] [ mobber |> Maybe.map .name |> Maybe.withDefault "Wut ?" |> text ]
        ]
