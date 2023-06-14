module Pages.Mob.Settings.PageView exposing (Props, view)

import Components.SecondaryPage
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.Duration as Duration exposing (Duration)
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
    { mob : MobName
    , devMode : Bool
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
    Components.SecondaryPage.view
        { onBack = props.onBack
        , title = "Settings"
        , icon = UI.Icons.Ion.settings
        , subTitle = Just "The settings are shared with the whole team"
        , content =
            Html.div
                [ Attr.css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , UI.Css.gap <| Size.rem 3
                    ]
                ]
                [ clockLengths props
                , playlist props
                ]
        }


playlist : Props msg -> Html msg
playlist props =
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


clockLengths : Props msg -> Html msg
clockLengths props =
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , UI.Css.gap <| Size.rem 0.6
            ]
        ]
        [ sectionTitle UI.Icons.Ion.clock "Clocks"
        , lengthRange
            { title = "Turn"
            , icon = UI.Icons.Custom.hourGlass
            , length = props.turnLength
            , onChange = props.onTurnLengthChange
            , min = 2
            , max = 15
            , devMode = props.devMode
            }
        , lengthRange
            { title = "Pomodoro"
            , icon = UI.Icons.Custom.tomato
            , length = props.pomodoro
            , onChange = props.onPomodoroChange
            , min = 10
            , max = 45
            , devMode = props.devMode
            }
        ]


lengthRange :
    { title : String
    , icon : Icon msg
    , length : Duration
    , onChange : Duration -> msg
    , min : Int
    , max : Int
    , devMode : Bool
    }
    -> Html msg
lengthRange props =
    let
        ( durationToInt, durationFromInt ) =
            if props.devMode then
                ( Duration.toSeconds, Duration.ofSeconds )

            else
                ( Duration.toMinutes, Duration.ofMinutes )
    in
    Html.div
        [ Attr.css
            [ Css.displayFlex
            , UI.Css.gap <| Size.rem 2
            , Css.alignItems Css.center
            ]
        ]
        [ props.icon
            { size = Size.rem 2
            , color = Palettes.monochrome.on.background
            }
        , Html.span
            [ Attr.css [ Css.width <| Css.rem 18 ] ]
            [ Html.text <| props.title ++ ": " ++ Duration.print props.length ]
        , UI.Range.View.view
            { onChange = durationFromInt >> props.onChange
            , min = props.min
            , max = props.max
            , value = props.length |> durationToInt
            }
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
            [ Css.width <| Css.pct 100
            , Css.property "aspect-ratio" "3/2"
            ]
        ]
        []
