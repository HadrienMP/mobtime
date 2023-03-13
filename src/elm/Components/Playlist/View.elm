module Components.Playlist.View exposing (view)

import Css
import Html.Styled as Html
import Html.Styled.Attributes as Attr
import Sounds
import UI.Css
import UI.Icons.Tape
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UI.Space as Space
import UI.Typography.Typography as Typography


view : Sounds.Profile -> Html.Html msg
view playlist =
    Row.row
        [ Attr.css
            [ Css.lineHeight <| Css.num 1.2
            , UI.Css.gap Space.s
            ]
        ]
        [ UI.Icons.Tape.display
            { size = Size.px 55
            , color = Palettes.monochrome.on.background
            }
        , Html.div []
            [ Html.div [ Attr.css [ Css.fontWeight Css.lighter ] ] [ Html.text "Playlist" ]
            , Html.div
                [ Attr.css [ Typography.fontSize Typography.l ]
                ]
                [ Html.text <| Sounds.title playlist ]
            ]
        ]
