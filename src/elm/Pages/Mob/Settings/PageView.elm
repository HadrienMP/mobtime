module Pages.Mob.Settings.PageView exposing (Props, view)

import Components.Form.Toggle.View
import Components.Form.Volume.View as VolumeView
import Components.SecondaryPage
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.Duration as Duration exposing (Duration, Unit(..))
import Model.MobName exposing (MobName)
import Sounds
import UI.Color as Color
import UI.Css
import UI.Icons.Common exposing (Icon)
import UI.Icons.Custom
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Palettes as Palettes
import UI.Range.View
import UI.Size as Size
import UI.Typography as Typography


type alias Props msg =
    { currentPlaylist : Sounds.Profile
    , devMode : Bool
    , mob : MobName
    , onBack : msg
    , onPlaylistChange : Sounds.Profile -> msg
    , onPomodoroChange : Duration -> msg
    , onTurnLengthChange : Duration -> msg
    , onExtremeModeChange : msg
    , extremeMode : Bool
    , pomodoro : Duration
    , turnLength : Duration
    , volume : VolumeView.Props msg
    }


view : Props msg -> Html msg
view props =
    Components.SecondaryPage.view
        { onBack = props.onBack
        , title = "Settings"
        , icon = UI.Icons.Ion.settings
        , subTitle = Just "The settings are shared with the team (except the volume)"
        , content =
            Html.div
                [ Attr.css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , UI.Css.gap <| Size.rem 3
                    ]
                ]
                [ viewPersonalSection props
                , viewClockLengths props
                , viewPlaylist props
                ]
        }


viewPersonalSection : Props msg -> Html msg
viewPersonalSection props =
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , UI.Css.gap <| Size.rem 0.6
            ]
        ]
        [ sectionTitle UI.Icons.Ion.user "Personnal"
        , VolumeView.display props.volume
        ]


viewClockLengths : Props msg -> Html msg
viewClockLengths props =
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , UI.Css.gap <| Size.rem 0.6
            ]
        ]
        [ sectionTitle UI.Icons.Ion.clock "Clocks"
        , if props.extremeMode then
            lengthRange
                { title = "Turn"
                , icon = UI.Icons.Custom.hourGlass
                , length = props.turnLength
                , onChange = props.onTurnLengthChange
                , min = 1
                , max = 120
                , unit = Seconds
                }

          else
            lengthRange
                { title = "Turn"
                , icon = UI.Icons.Custom.hourGlass
                , length = props.turnLength
                , onChange = props.onTurnLengthChange
                , min = 2
                , max = 15
                , unit = Minutes
                }
        , lengthRange
            { title = "Pomodoro"
            , icon = UI.Icons.Custom.tomato
            , length = props.pomodoro
            , onChange = props.onPomodoroChange
            , min = 10
            , max = 45
            , unit = Minutes
            }
        , viewExtremeMode props
        ]


sectionTitle : Icon msg -> String -> Html msg
sectionTitle icon title =
    Html.h3
        [ Attr.css
            [ Css.displayFlex
            , UI.Css.gap <| Size.rem 1
            , Css.borderBottom3 (Css.px 1) Css.solid <|
                Color.toElmCss <|
                    Palettes.monochrome.on.background
            , Css.paddingBottom <| Css.rem 0.4
            , Css.alignItems Css.center
            , Css.margin Css.zero
            ]
        ]
        [ icon
            { size = Size.rem 2
            , color = Palettes.monochrome.on.background
            }
        , Html.text title
        ]


lengthRange :
    { title : String
    , icon : Icon msg
    , length : Duration
    , onChange : Duration -> msg
    , min : Int
    , max : Int
    , unit : Duration.Unit
    }
    -> Html msg
lengthRange props =
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , UI.Css.gap <| Size.rem 1
            , Css.alignItems Css.center
            ]
        ]
        [ props.icon
            { size = Size.rem 2
            , color = Palettes.monochrome.on.background
            }
        , Html.div
            [ Attr.css
                [ Css.width <| Css.px 142
                , Css.flexShrink (Css.int 1)
                ]
            ]
            [ Html.text <| props.title ++ ": " ++ Duration.printLong props.length ]
        , Html.div
            [ Attr.css
                [ Css.flexGrow <| Css.int 1
                ]
            ]
            [ UI.Range.View.view
                { onChange = Duration.fromInt props.unit >> props.onChange
                , min = props.min
                , max = props.max
                , value = props.length |> Duration.toInt props.unit
                }
            ]
        ]


viewExtremeMode : Props msg -> Html msg
viewExtremeMode props =
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , UI.Css.gap <| Size.rem 1
            , Css.alignItems Css.center
            ]
        ]
        [ UI.Icons.Ion.fireball
            { size = Size.rem 2
            , color = Palettes.monochrome.on.background
            }
        , Html.div
            [ Attr.css
                [ Css.width <| Css.px 142
                , Css.displayFlex
                , UI.Css.gap <| Size.rem 0.4
                , Css.alignItems Css.center
                ]
            ]
            [ Html.text "Extreme Mode"
            , Html.span
                [ Attr.title "Allows for turn lenghts shorter than 2 minutes" ]
                [ UI.Icons.Ion.questionMark
                    { size = Size.rem 1
                    , color = Palettes.monochrome.on.background
                    }
                ]
            ]
        , Components.Form.Toggle.View.view
            { onToggle = props.onExtremeModeChange
            , value = props.extremeMode
            , labelOn = Just "On"
            , labelOff = Just "Off"
            }
        ]


viewPlaylist : Props msg -> Html msg
viewPlaylist props =
    Html.div [ Attr.css [ Css.displayFlex, Css.flexDirection Css.column, UI.Css.gap <| Size.rem 0.8 ] ]
        [ sectionTitle UI.Icons.Tape.display "Playlist"
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


viewProfile : { active : Sounds.Profile, current : Sounds.Profile, onChange : Sounds.Profile -> msg } -> Html msg
viewProfile { active, current, onChange } =
    Html.button
        [ Attr.css
            [ Css.border Css.zero
            , Css.border3 (Css.px 1) Css.solid <| Color.toElmCss <| Palettes.monochrome.on.background
            , Css.backgroundColor Css.transparent
            , Css.width <| Css.pct 49
            , Css.maxWidth <| Css.px 300
            , Css.padding Css.zero
            , Css.overflow Css.hidden
            , Css.position Css.relative
            , Css.marginBottom <| Css.rem 0.4
            , Css.displayFlex
            , Css.flexDirection Css.column
            ]
        , Evts.onClick (onChange current)
        ]
        [ Sounds.poster current |> viewPoster
        , Html.p
            [ Attr.css
                [ Css.padding2 (Css.rem 0.6) (Css.rem 1)
                , Css.margin Css.zero
                , Css.fontSize <| Css.rem 1
                , Css.backgroundColor <|
                    Color.toElmCss <|
                        if active == current then
                            Palettes.monochrome.surfaceActive

                        else
                            Palettes.monochrome.surface
                , Css.color <|
                    Color.toElmCss <|
                        if active == current then
                            Palettes.monochrome.on.surfaceActive

                        else
                            Palettes.monochrome.on.surface
                ]
            ]
            [ Html.text <| Sounds.title current ]
        , if current == active then
            Html.span
                [ Attr.css
                    [ Css.position Css.absolute
                    , Css.top <| Css.rem 0.6
                    , Css.left <| Css.rem 0.6
                    , Css.padding2 (Css.rem 0.2) (Css.rem 0.6)
                    , Css.backgroundColor <| Color.toElmCss <| Palettes.monochrome.surfaceActive
                    , Css.color <| Color.toElmCss <| Palettes.monochrome.on.surfaceActive
                    , Typography.fontSize Typography.s
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
            [ Css.width <| Css.px 214
            , Css.height <| Css.px 142
            , Css.property "object-fit" "cover"
            , Css.property "object-position" "top"
            ]
        ]
        []
