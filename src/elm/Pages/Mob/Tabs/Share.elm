module Pages.Mob.Tabs.Share exposing (..)

import Html.Styled as Html exposing (Html, button, div, span, strong, text)
import Html.Styled.Attributes exposing (class, id, title)
import Html.Styled.Events exposing (onClick)
import Js.Commands
import Model.MobName exposing (MobName)
import QRCode
import Shared exposing (Shared)
import Svg.Attributes as Svg
import Svg.Styled exposing (fromUnstyled)
import UI.Icons.Ion
import UI.Palettes
import UI.Rem
import Url



-- UPDATE


type Msg
    = PutLinkInPasteBin String


update : Msg -> Cmd Msg
update msg =
    case msg of
        PutLinkInPasteBin url ->
            url
                |> Js.Commands.CopyInPasteBin
                |> Js.Commands.send



-- VIEW


view : Shared -> MobName -> Html Msg
view shared mob =
    div [ id "share", class "tab" ]
        [ shareButton mob <| PutLinkInPasteBin <| Url.toString shared.url
        , shared.url
            |> Url.toString
            |> QRCode.fromString
            |> Result.map
                (QRCode.toSvg
                    [ Svg.width "300px"
                    , Svg.height "300px"
                    ]
                    >> fromUnstyled
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
        , UI.Icons.Ion.share
            { size = UI.Rem.Rem 1
            , color = UI.Palettes.monochrome.on.background
            }
        ]


shareText : MobName -> Html msg
shareText mob =
    span []
        [ text "You are in the "
        , strong [] [ text <| Model.MobName.print mob ]
        , text " mob"
        ]
