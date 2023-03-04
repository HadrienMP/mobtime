module Pages.Mob.Share.PageView exposing (Props, view)

import Components.SecondaryPage.View
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Model.MobName exposing (MobName)
import QRCode
import Svg.Attributes as SvgAttr
import UI.Button.View as Button
import UI.Column as Column
import UI.Icons.Ion


type alias Props msg =
    { url : String
    , copy : String -> msg
    , mob : MobName
    , onBack : msg
    }


view : Props msg -> Html msg
view props =
    Components.SecondaryPage.View.view
        { onBack = props.onBack
        , mob = props.mob
        , title = "Invite your team"
        , content =
            Column.column
                [ Attr.css
                    [ Css.alignItems Css.center
                    , Css.padding <| Css.rem 2
                    ]
                ]
                []
                [ Button.button
                    [ Attr.css
                        [ Css.maxWidth <| Css.px 250
                        , Css.width <| Css.px 250
                        ]
                    ]
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
        }
