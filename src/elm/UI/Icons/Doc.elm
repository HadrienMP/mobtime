module UI.Icons.Doc exposing (doc)

import Css
import ElmBook.Chapter exposing (chapter, renderComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import UI.Css
import UI.Icons.Captain
import UI.Icons.Custom
import UI.Icons.Ion
import UI.Icons.Keyboard
import UI.Icons.Tape
import UI.Icons.Tea
import UI.Palettes as Palettes
import UI.Rem as Rem


doc : Chapter x
doc =
    chapter "Icons"
        |> renderComponent
            ([ UI.Icons.Keyboard.display
             , UI.Icons.Captain.display
             , UI.Icons.Tape.display
             , UI.Icons.Tea.display
             , UI.Icons.Custom.elephant
             , UI.Icons.Custom.hourGlass
             , UI.Icons.Custom.rocket
             , UI.Icons.Custom.tomato
             , UI.Icons.Ion.back
             , UI.Icons.Ion.check
             , UI.Icons.Ion.clock
             , UI.Icons.Ion.close
             , UI.Icons.Ion.code
             , UI.Icons.Ion.copy
             , UI.Icons.Ion.delete
             , UI.Icons.Ion.error
             , UI.Icons.Ion.github
             , UI.Icons.Ion.home
             , UI.Icons.Ion.musicNote
             , UI.Icons.Ion.mute
             , UI.Icons.Ion.paperAirplane
             , UI.Icons.Ion.people
             , UI.Icons.Ion.play
             , UI.Icons.Ion.plus
             , UI.Icons.Ion.rotate
             , UI.Icons.Ion.settings
             , UI.Icons.Ion.share
             , UI.Icons.Ion.shuffle
             , UI.Icons.Ion.stop
             , UI.Icons.Ion.success
             , UI.Icons.Ion.user
             , UI.Icons.Ion.volumeHigh
             , UI.Icons.Ion.volumeLow
             ]
                |> List.map
                    (\x ->
                        x
                            { size = Rem.Rem 2
                            , color = Palettes.monochrome.on.background
                            }
                    )
                |> Html.div
                    [ Attr.css
                        [ Css.displayFlex
                        , UI.Css.gap <| Rem.Rem 1
                        , Css.flexWrap Css.wrap
                        ]
                    ]
            )
