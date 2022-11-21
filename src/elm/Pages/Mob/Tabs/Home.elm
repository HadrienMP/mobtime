module Pages.Mob.Tabs.Home exposing (..)

import UI.Footer
import Html.Styled exposing (Html, div, li, span, text, ul)
import Html.Styled.Attributes exposing (class, id)
import Js.Commands
import Model.MobName exposing (MobName)
import Model.Mobber exposing (Mobber)
import Model.Role exposing (Role)
import Model.State exposing (State)
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


view : MobName -> Url.Url -> State -> Html Msg
view mobName url state =
    div
        [ id "home", class "tab" ]
        [ Pages.Mob.Tabs.Share.shareButton mobName <| PutLinkInPasteBin url
        , roles state
        , UI.Footer.view
        ]


roles : State -> Html msg
roles state =
    Model.State.assignSpecialRoles state
        |> List.map roleView
        |> (\list ->
                case list of
                    [] ->
                        div [] []

                    _ ->
                        ul [ class "mobber-roles" ] list
           )


roleView : ( Role, Mobber ) -> Html msg
roleView ( role, mobber ) =
    li [ class "mobber-role" ]
        [ span [ class "role" ] [ role |> Model.Role.print |> text ]
        , span [ class "mobber" ] [ mobber.name |> text ]
        ]
