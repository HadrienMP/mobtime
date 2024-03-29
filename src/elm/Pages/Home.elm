module Pages.Home exposing (Model, Msg(..), init, update, view)

-- MODEL

import Components.Form.Volume.Field as Volume
import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Evts
import Lib.Toaster
import Model.MobName
import Pages.Mob.Routing
import Routing
import Shared exposing (Shared)
import Slug
import UI.Button.View as Button
import UI.Color as Color
import UI.Column as Column
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Palettes as Palettes
import UI.Row as Row
import UI.Size as Size
import UserPreferences
import View exposing (View)


type alias Model =
    { mobName : String
    }


init : ( Model, Effect Shared.Msg msg )
init =
    ( { mobName = ""
      }
    , Effect.none
    )



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
                    let
                        mob =
                            Slug.toString slug |> Model.MobName.MobName
                    in
                    ( model
                    , Effect.batch
                        [ { subRoute = Pages.Mob.Routing.Home, mob = mob }
                            |> Routing.Mob
                            |> Shared.pushUrl shared
                        , Effect.fromShared <| Shared.JoinMob mob
                        ]
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
    { title = "Mob Time"
    , modal = Nothing
    , body =
        Column.column []
            [ Column.Gap <| Size.rem 4 ]
            [ Html.header
                [ Attr.css
                    [ Css.displayFlex
                    , Css.justifyContent Css.spaceAround
                    ]
                ]
                [ UI.Icons.Tape.display
                    { size = Size.rem 8
                    , color = Palettes.monochrome.on.background
                    }
                , Html.h1
                    [ Attr.css
                        [ Css.fontSize <| Css.rem 3.8
                        , Css.paddingLeft <| Css.rem 1.3
                        , Css.lineHeight <| Css.num 1
                        ]
                    ]
                    [ Html.div [ Attr.css [ Css.fontWeight <| Css.bolder ] ] [ Html.text "Mob" ]
                    , Html.div [ Attr.css [ Css.fontWeight <| Css.lighter ] ] [ Html.text "Time" ]
                    ]
                ]
            , Html.form [ Evts.onSubmit JoinMob ]
                [ Column.column []
                    [ Column.Gap <| Size.rem 1 ]
                    [ Html.h2
                        [ Attr.css
                            [ Css.borderBottom3 (Css.rem 0.1) Css.solid <|
                                Color.toElmCss Palettes.monochrome.surface
                            , Css.paddingBottom <| Css.rem 0.4
                            , Css.textAlign Css.left
                            , Css.fontSize <| Css.rem 1.2
                            ]
                        ]
                        [ Html.text "Create a mob" ]
                    , mobField model
                    , volumeField shared

                    -- , p2pField shared
                    , Button.button
                        [ Attr.css
                            [ Css.width <| Css.pct 100
                            , Css.marginTop <| Css.rem 1
                            ]
                        ]
                        { content = Button.Both { icon = UI.Icons.Ion.paperAirplane, text = "Create" }
                        , variant = Button.Primary
                        , size = Button.M
                        , action = Button.Submit
                        }
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
    Row.row [ Attr.css [ Css.width <| Css.pct 100 ] ]


labelWitdh : Css.Style
labelWitdh =
    Css.width <| Css.pct 30


volumeField : Shared -> Html Msg
volumeField shared =
    Volume.view
        shared.preferences.volume
        { labelWidth = labelWitdh }
        |> Html.map VolumeMsg
