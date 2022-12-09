module Pages.Home exposing (..)

-- MODEL

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.Toaster
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
import UserPreferences
import View exposing (View)
import Volume


type alias Model =
    { mobName : String
    }


init : ( Model, Cmd msg )
init =
    ( { mobName = "" }, Cmd.none )



-- UPDATE


type Msg
    = MobNameChanged String
    | VolumeMsg Volume.Msg
    | JoinMob


update : Shared -> Model -> Msg -> ( Model, Effect Shared.Msg Msg )
update shared model msg =
    case msg of
        MobNameChanged name ->
            ( { model | mobName = name }
            , Effect.none
            )

        VolumeMsg subMsg ->
            ( model, Effect.fromShared <| Shared.PreferencesMsg <| UserPreferences.VolumeMsg subMsg )

        JoinMob ->
            case Slug.generate model.mobName of
                Just slug ->
                    ( model
                    , Slug.toString slug
                        |> Model.MobName.MobName
                        |> Routing.Mob
                        |> Shared.pushUrl shared
                    )

                Nothing ->
                    ( model
                    , Shared.toast <|
                        Lib.Toaster.error <|
                            "I was not able to create a url from your mob name. "
                                ++ "Please try another one. Maybe with less symbols ?"
                    )



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
                        , volumeField shared
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


volumeField : Shared -> Html Msg
volumeField shared =
    Volume.view
        shared.preferences.volume
        { labelWidth = labelWitdh }
        |> Html.map VolumeMsg
