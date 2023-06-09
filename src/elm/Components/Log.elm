module Components.Log exposing (Props, doc, view)

import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter as Chapter
import ElmBook.ElmCSS exposing (Chapter)
import Html.Styled
import UI.Button.RoundIcon
import UI.Icons.Ion
import UI.Palettes as Palettes


doc : Chapter x
doc =
    Chapter.chapter "Log"
        |> Chapter.withComponent
            (UI.Button.RoundIcon.view []
                { target = UI.Button.RoundIcon.Button <| logAction "Clicked"
                , text = "Logs"
                , icon = UI.Icons.Ion.bug
                , color = Palettes.monochrome.on.background
                }
            )
        |> Chapter.render """
<component />
"""


type alias Props msg =
    { onClick : msg }


view : List (Html.Styled.Attribute msg) -> Props msg -> Html.Styled.Html msg
view attributes props =
    UI.Button.RoundIcon.view attributes
        { target = UI.Button.RoundIcon.Button props.onClick
        , text = "Logs"
        , icon = UI.Icons.Ion.bug
        , color = Palettes.monochrome.on.background
        }
