module Pages.Mob.Tabs.Share exposing (..)

import Html exposing (Html, button, div, span, strong, text)
import Html.Attributes exposing (class, id, title)
import Html.Events exposing (onClick)
import Js.Commands
import Lib.Icons.Ion
import Model.MobName exposing (MobName)
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
                |> Js.Commands.CopyInPasteBin
                |> Js.Commands.send



-- VIEW


view : MobName -> Url.Url -> Html Msg
view mob url =
    div [ id "share", class "tab" ]
        [ shareButton mob <| PutLinkInPasteBin url
        , QRCode.fromString (Url.toString url)
            |> Result.map
                (QRCode.toSvg
                    [ Svg.width "300px"
                    , Svg.height "300px"
                    ]
                )
            |> Result.withDefault (Html.text "Error while encoding to QRCode.")
        ]


shareButton : MobName -> msg -> Html msg
shareButton mob shareMsg =
    button
        [ onClick shareMsg
        , id "share-link"
        , title "Copy this mob's link in your clipboard"
        ]
        [ shareText mob
        , Lib.Icons.Ion.share
        ]


shareText : MobName -> Html msg
shareText mob =
    span []
        [ text "You are in the "
        , strong [] [ text <| Model.MobName.print mob ]
        , text " mob"
        ]
