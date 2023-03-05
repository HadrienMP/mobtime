module UI.Typography.Doc exposing (doc)

import Css
import ElmBook.Chapter exposing (chapter, render, withComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Typography.Typography as Typography


phrase : String
phrase =
    "Without equality there can be no freedom"


doc : Chapter x
doc =
    chapter "Typography"
        |> withComponentList
            [ ( "xs", component Typography.xs )
            , ( "s", component Typography.s )
            , ( "m", component Typography.m )
            , ( "l", component Typography.l )
            , ( "xl", component Typography.xl )
            ]
        |> render """
```elm
Html.span 
  [ Attr.css [ Typography.s ] 
  [ Html.text "xxx" ]
```
<component with-label="xs"/>
<component with-label="s"/>
<component with-label="m"/>
<component with-label="l"/>
<component with-label="xl"/>
"""


component : Css.Style -> Html.Html msg
component typography =
    Html.span [ Attr.css [ typography ] ]
        [ Html.text phrase ]
