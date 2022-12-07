module Pages.Home exposing (..)

-- MODEL

import Browser.Navigation as Nav
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Js.Commands
import Lib.Toaster
import Lib.UpdateResult exposing (UpdateResult)
import Model.MobName
import Routing
import Shared exposing (Shared)
import Slug
import UI.Buttons
import UI.Color
import UI.Column
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Layout
import UI.Palettes
import UI.Rem
import UI.Row
import View exposing (View)


type alias Model =
    { mobName : String
    , volume : Int
    }


init : Shared -> ( Model, Cmd msg )
init shared =
    ( { mobName = ""
      , volume = shared.preferences.volume
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = MobNameChanged String
    | ChangeVolume Int
    | TestVolume
    | JoinMob


update : Shared -> Model -> Msg -> UpdateResult Model Msg
update shared model msg =
    case msg of
        MobNameChanged name ->
            { model = { model | mobName = name }
            , command = Cmd.none
            , toasts = []
            }

        ChangeVolume volume ->
            { model = { model | volume = volume }
            , command = Js.Commands.ChangeVolume volume |> Js.Commands.send
            , toasts = []
            }

        TestVolume ->
            { model = model
            , command = Js.Commands.TestTheSound |> Js.Commands.send
            , toasts = []
            }

        JoinMob ->
            case Slug.generate model.mobName of
                Just slug ->
                    { model = model
                    , command =
                        Nav.pushUrl shared.key <|
                            Routing.toUrl <|
                                Routing.Mob <|
                                    Model.MobName.MobName <|
                                        Slug.toString slug
                    , toasts = []
                    }

                Nothing ->
                    { model = model
                    , command = Cmd.none
                    , toasts = [ Lib.Toaster.error "I was not able to create a url from your mob name. Please try another one. Maybe with less symbols ?" ]
                    }



-- VIEW


view : Shared -> Model -> View Msg
view shared model =
    { title = "Login | Mob Time"
    , modal = Nothing
    , body =
        [ UI.Layout.forHome shared <|
            UI.Column.column []
                [ UI.Column.Gap <| UI.Rem.Rem 4 ]
                [ Html.header
                    [ Attr.css
                        [ Css.displayFlex
                        , Css.justifyContent Css.spaceAround
                        ]
                    ]
                    [ UI.Icons.Tape.display
                        { height = UI.Rem.Rem 8
                        , color = UI.Palettes.monochrome.on.background
                        }
                    , Html.h1
                        [ Attr.css
                            [ Css.fontSize <| Css.rem 3.8
                            , Css.paddingLeft <| Css.rem 1.3
                            ]
                        ]
                        [ Html.div [ Attr.css [ Css.fontWeight <| Css.bolder ] ] [ Html.text "Mob" ]
                        , Html.div [ Attr.css [ Css.fontWeight <| Css.lighter ] ] [ Html.text "Time" ]
                        ]
                    ]
                , Html.form [ Evts.onSubmit JoinMob ]
                    [ UI.Column.column []
                        [ UI.Column.Gap <| UI.Rem.Rem 1 ]
                        [ Html.h2
                            [ Attr.css
                                [ Css.borderBottom3 (Css.rem 0.1) Css.solid <|
                                    UI.Color.toElmCss UI.Palettes.monochrome.surface
                                , Css.paddingBottom <| Css.rem 0.4
                                , Css.textAlign Css.left
                                , Css.fontSize <| Css.rem 1.2
                                ]
                            ]
                            [ Html.text "Create a mob" ]
                        , mobField model
                        , volumeField model
                        , UI.Buttons.button
                            [ Attr.css
                                [ Css.width <| Css.pct 100
                                , Css.marginTop <| Css.rem 1
                                ]
                            ]
                            { content = UI.Buttons.Both { icon = UI.Icons.Ion.paperAirplane, text = "Create" }
                            , variant = UI.Buttons.Primary
                            , size = UI.Buttons.M
                            , action = UI.Buttons.Submit
                            }
                        ]
                    ]
                ]
        ]
    }


mobField : Model -> Html Msg
mobField model =
    formRow
        [ Html.label
            [ Attr.for "mob-name"
            , Attr.css
                [ Css.alignSelf Css.center
                , labelWitdh
                ]
            ]
            [ Html.text "Name" ]
        , Html.input
            [ Attr.id "mob-name"
            , Attr.type_ "text"
            , Evts.onInput MobNameChanged
            , Attr.placeholder "Awesome"
            , Attr.required True
            , Attr.min "4"
            , Attr.max "50"
            , Attr.value model.mobName
            , Attr.css [ Css.flexGrow <| Css.int 1 ]
            ]
            []
        ]


formRow : List (Html msg) -> Html msg
formRow =
    UI.Row.row
        [ Attr.css [ Css.width <| Css.pct 100 ] ]
        []


labelWitdh : Css.Style
labelWitdh =
    Css.width <| Css.pct 30


volumeField : Model -> Html Msg
volumeField model =
    formRow
        [ Html.label
            [ Attr.for "volume", Attr.css [ labelWitdh ] ]
            [ Html.text "Volume" ]
        , UI.Column.column [ Attr.css [ Css.flexGrow <| Css.int 1 ] ]
            [ UI.Column.Gap <| UI.Rem.Rem 0.4 ]
            [ UI.Row.row []
                []
                [ UI.Icons.Ion.volumeLow
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                , Html.input
                    [ Attr.id "volume"
                    , Attr.type_ "range"
                    , Evts.onInput
                        (String.toInt
                            >> Maybe.withDefault model.volume
                            >> ChangeVolume
                        )
                    , Attr.max "50"
                    , Attr.value <| String.fromInt model.volume
                    ]
                    []
                , UI.Icons.Ion.volumeHigh
                    { size = UI.Rem.Rem 1
                    , color = UI.Palettes.monochrome.on.background
                    }
                ]
            , UI.Buttons.button []
                { content = UI.Buttons.Both { icon = UI.Icons.Ion.musicNote, text = "Test the audio" }
                , variant = UI.Buttons.Secondary
                , size = UI.Buttons.S
                , action = UI.Buttons.OnPress <| Just TestVolume
                }
            ]
        ]
