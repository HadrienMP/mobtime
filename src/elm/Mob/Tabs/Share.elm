module Mob.Tabs.Share exposing (..)

import Html exposing (Html, button, div, i, span, strong, text)
import Html.Attributes exposing (class, id, title)
import Html.Events exposing (onClick)
import Out.Commands
import QRCode
import Svg.Attributes as Svg
import Url



-- UPDATE


type Msg
    = PutLinkInPasteBin Url.Url


update : Msg -> Cmd Msg
update msg =
    case msg of
        PutLinkInPasteBin url ->
            Url.toString url
                |> Out.Commands.CopyInPasteBin
                |> Out.Commands.send



-- VIEW


view : String -> Url.Url -> Html Msg
view mob url =
    div [ id "share", class "tab" ]
        [ shareButton mob url
        , QRCode.fromString (Url.toString url)
            |> Result.map
                (QRCode.toSvg
                    [ Svg.width "300px"
                    , Svg.height "300px"
                    ]
                )
            |> Result.withDefault (Html.text "Error while encoding to QRCode.")
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
