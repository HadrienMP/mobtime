module UI.Icons exposing (style)

import Css
import Css.Global
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Color exposing (RGBA255)
import UI.Rem exposing (Rem)


style :
    { class : String, size : Rem, colors : { normal : RGBA255, hover : RGBA255 } }
    -> Html msg
    -> Html msg
style { class, size, colors } child =
    Html.div [ Attr.class class ]
        [ Css.Global.global
            [ Css.Global.class class
                [ Css.Global.descendants
                    [ Css.Global.selector "svg"
                        [ Css.height <| UI.Rem.toElmCss size
                        , Css.width <| UI.Rem.toElmCss size
                        , Css.Global.descendants
                            [ Css.Global.everything [ Css.fill <| UI.Color.toElmCss colors.normal ]
                            ]
                        ]
                    ]
                , Css.hover
                    [ Css.Global.descendants
                        [ Css.Global.selector "svg *"
                            [ Css.fill <| UI.Color.toElmCss colors.hover
                            ]
                        ]
                    ]
                ]
            ]
        , child
        ]
