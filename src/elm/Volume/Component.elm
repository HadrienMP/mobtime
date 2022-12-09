module Volume.Component exposing (..)

import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Button.Component as Button
import UI.Column
import UI.Icons.Ion
import UI.Palettes
import UI.Range.Component
import UI.Rem
import UI.Row
import Volume.Type exposing (..)


display : { onChange : Volume -> msg, onTest : msg, volume : Volume } -> Html msg
display { onChange, onTest, volume } =
    UI.Row.row
        [ Attr.css [ Css.width <| Css.pct 100 ] ]
        []
        [ Html.label
            [ Attr.for "volume", Attr.css [ Css.width <| Css.pct 30 ] ]
            [ Html.text "Volume" ]
        , UI.Column.column [ Attr.css [ Css.flexGrow <| Css.int 1 ] ]
            [ UI.Column.Gap <| UI.Rem.Rem 0.4 ]
            [ UI.Row.row []
                [ UI.Row.Gap <| UI.Rem.Rem 0.4 ]
                [ UI.Icons.Ion.volumeLow
                    { size = UI.Rem.Rem 2
                    , color = UI.Palettes.monochrome.on.background
                    }
                , UI.Range.Component.display
                    { onChange = onChange << Volume
                    , min = 0
                    , max = 50
                    , value = open volume
                    }
                , UI.Icons.Ion.volumeHigh
                    { size = UI.Rem.Rem 2
                    , color = UI.Palettes.monochrome.on.background
                    }
                ]
            , Button.button []
                { content = Button.Both { icon = UI.Icons.Ion.musicNote, text = "Test the audio" }
                , variant = Button.Secondary
                , size = Button.S
                , action = Button.OnPress <| Just onTest
                }
            ]
        ]
