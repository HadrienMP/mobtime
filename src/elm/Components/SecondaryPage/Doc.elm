module Components.SecondaryPage.Doc exposing (theChapter)

import Components.SecondaryPage.View
import ElmBook.Actions exposing (logAction)
import ElmBook.Chapter exposing (chapter, render, withComponent)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import UI.Rem as Rem
import Utils


theChapter : Chapter x
theChapter =
    chapter "Secondary Page"
        |> withComponent
            (Components.SecondaryPage.View.view
                { onBack = logAction "Back"
                , title = "My Page"
                , mob = MobName "Awesome"
                , content = Utils.placeholder <| Rem.Rem 10
                }
            )
        |> render """
<component />
```elm
type Msg
    = Back
    | ...

Components.SecondaryPage.View.view
    { onBack = Back
    , title = "My Page"
    , mob = MobName "Awesome"
    , content = Utils.placeholder <| Rem.Rem 10
    }
```
"""
