module Pages.Home exposing (..)

-- MODEL

import Browser.Navigation as Nav
import Html.Styled exposing (button, div, form, h1, header, input, label, text)
import Html.Styled.Attributes as Attr exposing (class, for, id, placeholder, required, type_, value)
import Html.Styled.Events exposing (onInput, onSubmit)
import UI.Icons.Ion
import Lib.Toaster
import Lib.UpdateResult exposing (UpdateResult)
import Slug
import UI.Footer
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


update : Model -> Msg -> Nav.Key -> UpdateResult Model Msg
update model msg navKey =
    case msg of
        MobNameChanged name ->
            { model = { model | mobName = name }, command = Cmd.none, toasts = [] }

        JoinMob ->
            case Slug.generate model.mobName of
                Just slug ->
                    { model = model
                    , command = Nav.pushUrl navKey <| "/mob/" ++ Slug.toString slug
                    , toasts = []
                    }

                Nothing ->
                    { model = model
                    , command = Cmd.none
                    , toasts = [ Lib.Toaster.error "I was not able to create a url from your mob name. Please try another one. Maybe with less symbols ?" ]
                    }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Login | Mob Time"
    , body =
        [ div
            [ id "login", class "container" ]
            [ header []
                [ h1 [] [ text "Mob Time" ]
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
                , button
                    [ type_ "submit", class "labelled-icon-button" ]
                    [ UI.Icons.Ion.paperAirplane
                    , text "Join"
                    ]
                ]
            , UI.Footer.view
            ]
        ]
    }
