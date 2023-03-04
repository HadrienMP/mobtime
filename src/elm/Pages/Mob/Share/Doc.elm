module Pages.Mob.Share.Doc exposing (theChapter)

import ElmBook.Actions exposing (logAction, logActionWithString)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Model.MobName exposing (MobName(..))
import Pages.Mob.Share.Button
import Pages.Mob.Share.PageView
import UI.Palettes as Palettes


theChapter : Chapter x
theChapter =
    chapter "Share"
        |> renderComponentList
            [ ( "Button"
              , Pages.Mob.Share.Button.view []
                    { sharePage = "https://mob.cassette.tools/awesome/share"
                    , color = Palettes.monochrome.on.background
                    }
              )
            , ( "Page"
              , Pages.Mob.Share.PageView.view
                    { url = "https://mobtime.hadrienmp.fr/mob/awesome"
                    , copy = logActionWithString "Copied"
                    , mob = MobName "Awesome"
                    , onBack = logAction "Back"
                    }
              )
            ]
