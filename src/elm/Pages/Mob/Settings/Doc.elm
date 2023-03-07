module Pages.Mob.Settings.Doc exposing (theChapter)

import ElmBook.Actions exposing (logAction, logActionWith)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Lib.Duration
import Model.MobName exposing (MobName(..))
import Pages.Mob.Settings.PageView as Page
import Sounds


theChapter : Chapter x
theChapter =
    chapter "Settings"
        |> renderComponentList
            [ ( "Page"
              , Page.view
                    { mob = MobName "Awesome"
                    , onBack = logAction "Back"
                    , onTurnLengthChange = logActionWith Lib.Duration.print "Turn changed"
                    , turnLength = Lib.Duration.ofMinutes 6
                    , onPomodoroChange = logActionWith Lib.Duration.print "Pomodoro changed"
                    , pomodoro = Lib.Duration.ofMinutes 25
                    , currentPlaylist = Sounds.ClassicWeird
                    , onPlaylistChange = logActionWith Sounds.title "Playlist changed"
                    }
              )
            ]
