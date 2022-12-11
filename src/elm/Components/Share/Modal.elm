module Components.Share.Modal exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import QRCode
import Svg.Attributes as SvgAttr
import UI.Button.View as Button
import UI.Column
import UI.Icons.Ion
import UI.Rem
import UI.Text


type alias Props msg =
    { url : String
    , copy : String -> msg
    }


view : Props msg -> Html msg
view props =
    UI.Column.column
        [ Attr.css
            [ Css.width <| Css.px 300
            , Css.textAlign Css.center
            ]
        ]
        [ UI.Column.Gap <| UI.Rem.Rem 1 ]
        [ UI.Text.h2 "Invite your team!"
        , Button.button []
            { size = Button.M
            , variant = Button.Primary
            , content = Button.Both { icon = UI.Icons.Ion.copy, text = "Copy the link" }
            , action = Button.OnPress <| Just <| props.copy props.url
            }
        , props.url
            |> QRCode.fromString
            |> Result.map
                (QRCode.toSvg
                    [ SvgAttr.width "300px"
                    , SvgAttr.height "300px"

                    -- , SvgAttr.viewBox "20 20 125 125"
                    ]
                    >> Html.fromUnstyled
                )
            |> Result.withDefault (Html.text "Error while encoding to QRCode.")
        ]
