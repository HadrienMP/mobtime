module Pages.Mob.Profile.View exposing (Props, view)

import Components.Form.Volume.View as Volume
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Model.MobName exposing (MobName)
import UI.Button.View as Button
import UI.Color as Color
import UI.Column as Column
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Text as Text
import UI.Text.View


type alias Props msg =
    { mob : MobName
    , volume : Volume.Props msg
    , onJoin : msg
    }


view : Props msg -> Html msg
view props =
    Column.column []
        [ Column.Gap <| Size.rem 3 ]
        [ head props
        , fields props
        , Button.button []
            { content =
                Button.Both <|
                    { icon = UI.Icons.Ion.paperAirplane
                    , text = "Join"
                    }
            , variant = Button.Primary
            , size = Button.M
            , action = Button.OnPress <| Just props.onJoin
            }
        ]


head : Props msg -> Html msg
head _ =
    Column.column []
        [ Column.Gap <| Size.rem 0.4 ]
        [ Row.row
            [ Attr.css
                [ Css.justifyContent Css.spaceBetween
                , Css.borderBottom3 (Css.px 2)
                    Css.solid
                    (Color.toElmCss Palettes.monochrome.surface)
                , Css.paddingBottom <| Css.rem 1
                ]
            ]
            []
            [ Text.h2 [] "Your Profile"
            ]
        , UI.Text.View.light "Setup your personal preferences before joining your teammates"
        ]


fields : Props msg -> Html msg
fields props =
    Column.column []
        [ Column.Gap <| Size.rem 1.4 ]
        [ Volume.display props.volume
        ]
