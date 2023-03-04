module Components.Form.Toggle.View exposing (Props, view)

import Css
import Html.Styled as Html exposing (Html, label, text)
import Html.Styled.Attributes exposing (css, for)
import UI.Toggle.View


type alias Props msg =
    { id : String
    , label : String
    , labelOn : Maybe String
    , labelOff : Maybe String
    , onToggle : msg
    , value : Bool
    }


view : Props msg -> Html msg
view props =
    Html.div
        [ css
            [ Css.displayFlex
            , Css.alignItems Css.center
            ]
        ]
        [ label [ for props.id, css [ Css.flexGrow <| Css.num 1 ] ] [ text props.label ]
        , smallLabel props.labelOff
        , UI.Toggle.View.view
            { onToggle = props.onToggle
            , value = props.value
            }
        , smallLabel props.labelOn
        ]


smallLabel : Maybe String -> Html msg
smallLabel label =
    case label of
        Just value ->
            Html.span
                [ css
                    [ Css.padding2 Css.zero <| Css.px 10
                    , Css.fontSize <| Css.em 0.8
                    ]
                ]
                [ text value ]

        Nothing ->
            Html.span [] []
