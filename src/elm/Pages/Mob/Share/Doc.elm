module Pages.Mob.Share.Doc exposing (theChapter)

import ElmBook.Actions exposing (logAction, logActionWithString)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import Pages.Mob.Share.PageView


theChapter : Chapter x
theChapter =
    chapter "Share"
        |> renderComponentList
            [ ( "Page"
              , Pages.Mob.Share.PageView.view
                    { url = "https://mobtime.hadrienmp.fr/mob/awesome"
                    , copy = logActionWithString "Copied"
                    , mob = MobName "Awesome"
                    , onBack = logAction "Back"
                    }
              )
            ]
