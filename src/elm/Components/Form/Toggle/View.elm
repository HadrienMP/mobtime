module Components.Form.Toggle.View exposing (Props, view)

import Css
import Html.Styled as Html exposing (Html, text)
import Html.Styled.Attributes exposing (css)
import UI.Css
import UI.Size as Size
import UI.Toggle.View


type alias Props msg =
    { id : String
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
            , UI.Css.gap <| Size.px 10
            ]
        ]
        [ smallLabel props.labelOff
        , UI.Toggle.View.view
            { id = props.id
            , onToggle = props.onToggle
            , value = props.value
            }
        , smallLabel props.labelOn
        ]


smallLabel : Maybe String -> Html msg
smallLabel label =
    case label of
        Just value ->
            Html.span
                [ css [ Css.fontSize <| Css.em 0.8 ] ]
                [ text value ]

        Nothing ->
            Html.span [] []
