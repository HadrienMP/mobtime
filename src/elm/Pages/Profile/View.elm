module Pages.Profile.View exposing (..)

import Components.Form.Volume.View as Volume
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Model.MobName exposing (MobName)
import UI.Button.View as Button
import UI.Color
import UI.Column
import UI.Icons.Ion
import UI.Palettes
import UI.Rem
import UI.Row
import UI.Text
import UI.Text.View
import UI.Toggle.View


type alias Props msg =
    { mob : Maybe MobName
    , secondsToggle : UI.Toggle.View.Props msg
    , volume : Volume.Props msg
    , onJoin : msg
    }


view : Props msg -> Html msg
view props =
    UI.Column.column []
        [ UI.Column.Gap <| UI.Rem.Rem 3 ]
        [ head props
        , fields props
        , Button.button []
            { content =
                Button.Both <|
                    case props.mob of
                        Just _ ->
                            { icon = UI.Icons.Ion.paperAirplane
                            , text = "Join"
                            }

                        Nothing ->
                            { icon = UI.Icons.Ion.back, text = "Back" }
            , variant = Button.Primary
            , size = Button.M
            , action = Button.OnPress <| Just props.onJoin
            }
        ]


head : Props msg -> Html msg
head props =
    UI.Column.column []
        [ UI.Column.Gap <| UI.Rem.Rem 0.4 ]
        [ UI.Row.row
            [ Attr.css
                [ Css.justifyContent Css.spaceBetween
                , Css.borderBottom3 (Css.px 2)
                    Css.solid
                    (UI.Color.toElmCss UI.Palettes.monochrome.surface)
                , Css.paddingBottom <| Css.rem 1
                ]
            ]
            []
            [ UI.Text.h2 [] "Your Profile"
            ]
        , case props.mob of
            Just _ ->
                UI.Text.View.light "Setup your personal preferences before joining your teammates"

            Nothing ->
                Html.div [] []
        ]


fields : Props msg -> Html msg
fields props =
    UI.Column.column []
        [ UI.Column.Gap <| UI.Rem.Rem 1.4 ]
        [ Volume.display props.volume
        , UI.Row.row [ Attr.css [ Css.justifyContent Css.spaceBetween, Css.alignItems Css.center ] ]
            []
            [ Html.text "Display seconds in clocks"
            , UI.Toggle.View.view props.secondsToggle
            ]
        ]
