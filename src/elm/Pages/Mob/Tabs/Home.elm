module Pages.Mob.Tabs.Home exposing (..)

import Footer
import Html exposing (Html, div, li, span, text, ul)
import Html.Attributes exposing (class, id)
import Js.Commands
import Model.Mobber exposing (Mobber)
import Model.Mobbers exposing (Mobbers)
import Pages.Mob.Tabs.Share
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
        [ Pages.Mob.Tabs.Share.shareButton mobName <| PutLinkInPasteBin url
        , roles mobbers
        , Footer.view
        ]


roles : Mobbers -> Html msg
roles mobbers =
    Model.Mobbers.assignRoles mobbers
        |> List.take 3
        |> List.map roleView
        |> (\list ->
                case list of
                    [] ->
                        div [] []

                    _ ->
                        ul [ class "mobber-roles" ] list
           )


roleView : ( String, Mobber ) -> Html msg
roleView ( role, mobber ) =
    li [ class "mobber-role" ]
        [ span [ class "role" ] [ role |> text ]
        , span [ class "mobber" ] [ mobber.name |> text ]
        ]
