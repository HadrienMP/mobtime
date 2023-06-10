module UI.Typography exposing (doc, fontSize, l, m, s, xl, xs)

import Css
import ElmBook.Chapter exposing (chapter, render, withComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Size as Size



-- Doc


phrase : String
phrase =
    "Without equality there can be no freedom"


doc : Chapter x
doc =
    chapter "Typography"
        |> withComponentList
            [ ( "xs", component xs )
            , ( "s", component s )
            , ( "m", component m )
            , ( "l", component l )
            , ( "xl", component xl )
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


component : Size.Size -> Html.Html msg
component typography =
    Html.span [ Attr.css [ fontSize typography ] ]
        [ Html.text phrase ]



-- Typography


scaled : Int -> Float
scaled scale =
    0.6 * (1.3 ^ toFloat scale) |> (*) 10 |> round |> (\x -> toFloat x / 10)


xs : Size.Size
xs =
    Size.rem <| scaled 0


s : Size.Size
s =
    Size.rem <| scaled 1


m : Size.Size
m =
    Size.rem <| scaled 2


l : Size.Size
l =
    Size.rem <| scaled 3


xl : Size.Size
xl =
    Size.rem <| scaled 4


fontSize : Size.Size -> Css.Style
fontSize =
    Css.fontSize << Size.toElmCss
