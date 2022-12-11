module Components.Share.Button exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import UI.Color exposing (RGBA255)
import UI.Icons.Ion
import UI.Rem


type alias Props msg =
    { onClick : msg
    , color : RGBA255
    }


view : Props msg -> Html msg
view props =
    Html.button
        [ Attr.css
            [ Css.border Css.zero
            , Css.backgroundColor Css.transparent
            , Css.cursor Css.pointer
            ]
        , Evts.onClick props.onClick
        ]
        [ UI.Icons.Ion.share
            { size = UI.Rem.Rem 1.4
            , color = props.color
            }
        ]
