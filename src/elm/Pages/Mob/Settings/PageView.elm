module Pages.Mob.Settings.PageView exposing (..)

import Components.SecondaryPage.View
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.Duration exposing (Duration)
import Model.MobName exposing (MobName)
import Sounds
import UI.Color
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Icons.Custom
import UI.Icons.Tape
import UI.Palettes
import UI.Range.View
import UI.Rem


type alias Props msg =
    { mob : MobName
    , onBack : msg
    , onTurnLengthChange : Duration -> msg
    , turnLength : Duration
    , onPomodoroChange : Duration -> msg
    , pomodoro : Duration
    , currentPlaylist : Sounds.Profile
    , onPlaylistChange : Sounds.Profile -> msg
    }


view : Props msg -> Html msg
view props =
    Components.SecondaryPage.View.view
        { onBack = props.onBack
        , mob = props.mob
        , title = "Settings"
        , content =
            Html.div
                [ Attr.css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , UI.Css.gap <| UI.Rem.Rem 2
                    ]
                ]
                [ Html.text "The settings are shared with the whole team"
                , lengthRange
                    { title = "Turn"
                    , icon = UI.Icons.Custom.hourGlass
                    , length = props.turnLength
                    , onChange = props.onTurnLengthChange
                    , min = Lib.Duration.ofMinutes 2
                    , max = Lib.Duration.ofMinutes 15
                    }
                , lengthRange
                    { title = "Pomodoro"
                    , icon = UI.Icons.Custom.tomato
                    , length = props.pomodoro
                    , onChange = props.onPomodoroChange
                    , min = Lib.Duration.ofMinutes 10
                    , max = Lib.Duration.ofMinutes 45
                    }
                , Html.h3
                    [ Attr.css
                        [ Css.displayFlex
                        , UI.Css.gap <| UI.Rem.Rem 1
                        , Css.borderBottom3 (Css.px 1) Css.solid <|
                            UI.Color.toElmCss <|
                                UI.Palettes.monochrome.on.background
                        , Css.paddingBottom <| Css.rem 0.4
                        , Css.alignItems Css.center
                        , Css.margin Css.zero
                        ]
                    ]
                    [ UI.Icons.Tape.display
                        { height = UI.Rem.Rem 1.4
                        , color = UI.Palettes.monochrome.on.background
                        }
                    , Html.text "Playlist"
                    ]
                , Html.div
                    [ Attr.css
                        [ Css.displayFlex
                        , Css.flexWrap Css.wrap
                        , Css.justifyContent Css.spaceBetween
                        ]
                    ]
                    (Sounds.allProfiles
                        |> List.map
                            (\profile ->
                                viewProfile
                                    { active = props.currentPlaylist
                                    , current = profile
                                    , onChange = props.onPlaylistChange
                                    }
                            )
                    )
                ]
        }


lengthRange :
    { title : String
    , icon : Icon msg
    , length : Duration
    , onChange : Duration -> msg
    , min : Duration
    , max : Duration
    }
    -> Html msg
lengthRange props =
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , UI.Css.gap <| UI.Rem.Rem 2
            , Css.alignItems Css.center
            ]
        ]
        [ props.icon
            { size = UI.Rem.Rem 2
            , color = UI.Palettes.monochrome.on.background
            }
        , Html.span
            [ Attr.css [ Css.width <| Css.rem 18 ] ]
            [ Html.text <| props.title ++ ": " ++ Lib.Duration.print props.length ]
        , UI.Range.View.view
            { onChange = Lib.Duration.ofMinutes >> props.onChange
            , min = Lib.Duration.toMinutes props.min
            , max = Lib.Duration.toMinutes props.max
            , value = props.length |> Lib.Duration.toMinutes
            }
        ]


viewProfile : { active : Sounds.Profile, current : Sounds.Profile, onChange : Sounds.Profile -> msg } -> Html msg
viewProfile { active, current, onChange } =
    Html.button
        [ Attr.css
            [ Css.border Css.zero
            , Css.backgroundColor Css.transparent
            , Css.maxWidth <| Css.pct 49
            , Css.padding Css.zero
            , Css.overflow Css.hidden
            , Css.position Css.relative
            , Css.marginBottom <| Css.rem 0.4
            , Css.displayFlex
            , Css.flexDirection Css.column
            , UI.Css.gap <| UI.Rem.Rem 0.1
            ]
        , Evts.onClick (onChange current)
        ]
        [ Sounds.poster current |> viewPoster
        , Html.p
            [ Attr.css
                [ Css.padding2 (Css.rem 0.6) (Css.rem 1)
                , Css.margin Css.zero
                , Css.fontSize <| Css.rem 1
                , UI.Css.roundBorder
                , Css.backgroundColor <|
                    UI.Color.toElmCss <|
                        if active == current then
                            UI.Palettes.monochrome.surfaceActive

                        else
                            UI.Palettes.monochrome.surface
                , Css.color <|
                    UI.Color.toElmCss <|
                        if active == current then
                            UI.Palettes.monochrome.on.surfaceActive

                        else
                            UI.Palettes.monochrome.on.surface
                ]
            ]
            [ Html.text <| Sounds.title current ]
        , if current == active then
            Html.span
                [ Attr.css
                    [ Css.position Css.absolute
                    , Css.top <| Css.rem 1
                    , Css.left <| Css.rem 1
                    , UI.Css.roundBorder
                    , Css.padding2 (Css.rem 0.4) (Css.rem 1)
                    , Css.backgroundColor <| UI.Color.toElmCss <| UI.Palettes.monochrome.surfaceActive
                    , Css.color <| UI.Color.toElmCss <| UI.Palettes.monochrome.on.surfaceActive
                    ]
                ]
                [ Html.text "Selected" ]

          else
            Html.span [] []
        ]


viewPoster : Sounds.Image -> Html msg
viewPoster { url, alt } =
    Html.img
        [ Attr.src url
        , Attr.alt alt
        , Attr.css
            [ Css.width <| Css.pct 100
            , Css.border3 (Css.px 1) Css.solid <| UI.Color.toElmCss <| UI.Palettes.monochrome.on.background
            , UI.Css.roundBorder
            , Css.property "aspect-ratio" "3/2"
            ]
        ]
        []
