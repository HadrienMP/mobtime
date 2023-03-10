module UI.Button.Doc exposing (theChapter)

import Css
import ElmBook.Actions
import ElmBook.Chapter exposing (chapter, render, withComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled.Attributes as Attr
import UI.Button.View as Button
import UI.Icons.Ion
import UI.Row as Row
import UI.Size as Size


theChapter : Chapter x
theChapter =
    let
        props =
            { content =
                \size ->
                    Button.Both
                        { icon = UI.Icons.Ion.paperAirplane
                        , text = sizeToString size
                        }
            , variant = Button.Primary
            }
    in
    chapter "Buttons"
        |> withComponentList
            [ ( "Primary", component props )
            , ( "Secondary", component { props | variant = Button.Secondary } )
            , ( "Text only", component { props | content = Button.Text << sizeToString } )
            , ( "Icon only", component { props | content = always <| Button.Icon UI.Icons.Ion.check } )
            ]
        |> render """
## With icon
```elm
type Msg
  = ClickedButton
  | ...
  
Button.button []
  { content = 
      Button.Both
        { icon = UI.Icons.Ion.paperAirplane
        , text = "Size S"
        }
  , variant = Button.Primary
  , size = Button.S
  , action = Button.OnPress <| Just ClickedButton
  }
```

<component with-label="Primary" />
<component with-label="Secondary" />

## Text only
```elm
Button.button []
  { content = Button.Text "Size S"
  , variant = Button.Primary
  , size = Button.S
  , action = Button.OnPress <| Just ClickedButton
  }
```
<component with-label="Text only"/>

## Icon only
```elm
Button.button []
  { content = Button.Icon UI.Icons.Ion.check
  , variant = Button.Primary
  , size = Button.S
  , action = Button.OnPress <| Just ClickedButton
  }
```
<component with-label="Icon only"/>

"""


sizes =
    [ Button.XS, Button.S, Button.M, Button.L ]


sizeToString : Button.Size -> String
sizeToString size =
    case size of
        Button.XS ->
            "Size XS"

        Button.S ->
            "Size S"

        Button.M ->
            "Size M"

        Button.L ->
            "Size L"


component props =
    Row.row [ Attr.css [ Css.alignItems Css.flexStart ] ]
        [ Row.Gap <| Size.rem 0.6 ]
        (sizes
            |> List.map
                (\size ->
                    Button.button []
                        { content = props.content size
                        , variant = props.variant
                        , size = size
                        , action = Button.OnPress <| Just <| ElmBook.Actions.logAction "Click"
                        }
                )
        )
