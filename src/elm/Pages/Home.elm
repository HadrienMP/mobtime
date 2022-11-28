module Pages.Home exposing (..)

-- MODEL

import Browser.Navigation as Nav
import Css
import Html.Styled exposing (div, form, h1, header, input, label, text)
import Html.Styled.Attributes as Attr exposing (class, for, id, placeholder, required, type_, value)
import Html.Styled.Events exposing (onInput, onSubmit)
import Lib.Toaster
import Lib.UpdateResult exposing (UpdateResult)
import Model.MobName
import Routing
import Shared exposing (Shared)
import Slug
import UI.Buttons
import UI.Icons.Ion
import UI.Icons.Tape
import UI.Layout
import UI.Palettes
import UI.Rem
import View exposing (View)


type alias Model =
    { mobName : String
    }


init : ( Model, Cmd msg )
init =
    ( { mobName = "" }, Cmd.none )



-- UPDATE


type Msg
    = MobNameChanged String
    | JoinMob


update : Shared -> Model -> Msg -> UpdateResult Model Msg
update shared model msg =
    case msg of
        MobNameChanged name ->
            { model = { model | mobName = name }, command = Cmd.none, toasts = [] }

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
            div
                [ id "login"
                , class "container"
                ]
                [ div []
                    [ header
                        [ Attr.css
                            [ Css.displayFlex
                            , Css.paddingBottom <| Css.rem 2
                            , Css.justifyContent Css.spaceAround
                            ]
                        ]
                        [ UI.Icons.Tape.display
                            { height = UI.Rem.Rem 8
                            , color = UI.Palettes.monochrome.on.background
                            }
                        , h1
                            [ Attr.css
                                [ Css.fontSize <| Css.rem 3.8
                                , Css.paddingLeft <| Css.rem 1.3
                                ]
                            ]
                            [ div [ Attr.css [ Css.fontWeight <| Css.bolder ] ] [ text "Mob" ]
                            , div [ Attr.css [ Css.fontWeight <| Css.lighter ] ] [ text "Time" ]
                            ]
                        ]
                    , form [ onSubmit JoinMob ]
                        [ div [ class "form-field" ]
                            [ label
                                [ for "mob-name" ]
                                [ text "What's your mob?" ]
                            , input
                                [ id "mob-name"
                                , type_ "text"
                                , onInput MobNameChanged
                                , placeholder "Awesome"
                                , required True
                                , Attr.min "4"
                                , Attr.max "50"
                                , value model.mobName
                                ]
                                []
                            ]
                        , UI.Buttons.button [ Attr.css [ Css.width <| Css.pct 100 ] ]
                            { content = UI.Buttons.Both { icon = UI.Icons.Ion.paperAirplane, text = "Join" }
                            , variant = UI.Buttons.Primary
                            , size = UI.Buttons.M
                            , action = UI.Buttons.Submit
                            }
                        ]
                    ]
                ]
        ]
    }
