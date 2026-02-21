module Pages.Mob.Settings.Doc exposing (theChapter)

import Components.Form.Volume.Type as Volume
import ElmBook.Actions exposing (logAction, logActionWith)
import ElmBook.Chapter exposing (chapter, renderComponentList)
import ElmBook.ElmCSS exposing (Chapter)
import Lib.Duration
import Model.MobName exposing (MobName(..))
import Pages.Mob.Settings.PageView as Page
import Playlist.ClassicWeird exposing (classicWeird)


theChapter : Chapter x
theChapter =
    chapter "Settings"
        |> renderComponentList
            [ ( "Page"
              , Page.view
                    { currentPlaylist = classicWeird.code
                    , devMode = False
                    , mob = MobName "Awesome"
                    , onBack = logAction "Back"
                    , onPlaylistChange = logActionWith .title "Playlist changed"
                    , onPomodoroChange = logActionWith Lib.Duration.print "Pomodoro changed"
                    , onTurnLengthChange = logActionWith (Lib.Duration.toLongString >> String.join " ") "Turn changed"
                    , onExtremeModeChange = logAction "Extreme mode toggled"
                    , pomodoro = Lib.Duration.ofMinutes 25
                    , extremeMode = False
                    , turnLength = Lib.Duration.ofMinutes 6
                    , volume =
                        { onChange = always <| logAction "Volume change"
                        , onTest = logAction "Test audio at level"
                        , volume = Volume.Volume 15
                        }
                    }
              )
            , ( "Extreme Mode"
              , Page.view
                    { currentPlaylist = classicWeird.code
                    , devMode = False
                    , mob = MobName "Awesome"
                    , onBack = logAction "Back"
                    , onPlaylistChange = logActionWith .title "Playlist changed"
                    , onPomodoroChange = logActionWith Lib.Duration.print "Pomodoro changed"
                    , onTurnLengthChange = logActionWith (Lib.Duration.toLongString >> String.join " ") "Turn changed"
                    , onExtremeModeChange = logAction "Extreme mode toggled"
                    , pomodoro = Lib.Duration.ofMinutes 25
                    , extremeMode = True
                    , turnLength = Lib.Duration.ofMinutes 1
                    , volume =
                        { onChange = always <| logAction "Volume change"
                        , onTest = logAction "Test audio at level"
                        , volume = Volume.Volume 15
                        }
                    }
              )
            ]
