module Components.Form.Volume.View exposing (Props, display)

import Components.Form.Volume.Type exposing (..)
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import UI.Button.View as Button
import UI.Column as Column
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Range.View
import UI.Row as Row
import UI.Size as Size


type alias Props msg =
    { onChange : Volume -> msg
    , onTest : msg
    , volume : Volume
    }


display : Props msg -> Html msg
display { onChange, onTest, volume } =
    Row.row
        [ Attr.css [ Css.width <| Css.pct 100 ] ]
        []
        [ Html.label
            [ Attr.for "volume", Attr.css [ Css.width <| Css.pct 30 ] ]
            [ Html.text "Volume" ]
        , Column.column [ Attr.css [ Css.flexGrow <| Css.int 1 ] ]
            [ Column.Gap <| Size.rem 0.4 ]
            [ Row.row []
                [ Row.Gap <| Size.rem 0.4 ]
                [ UI.Icons.Ion.volumeLow
                    { size = Size.rem 2
                    , color = Palettes.monochrome.on.background
                    }
                , UI.Range.View.view
                    { onChange = onChange << Volume
                    , min = 0
                    , max = 50
                    , value = open volume
                    }
                , UI.Icons.Ion.volumeHigh
                    { size = Size.rem 2
                    , color = Palettes.monochrome.on.background
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
