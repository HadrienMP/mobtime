module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Lib.BatchMsg
import Lib.Toast
import Login
import Mob.Main
import Out.Commands
import Out.Events
import Out.EventsMapping as EventsMapping exposing (EventsMapping)
import Pages
import Url
import UserPreferences



-- MAIN


main : Program (Maybe UserPreferences.Model) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { session : Pages.Session
    , userPreferences : UserPreferences.Model
    , pageModel : Pages.PageModel
    , toasts : Lib.Toast.Toasts
    }


init : Maybe UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init maybePreference url key =
    let
        userPreference =
            Maybe.withDefault UserPreferences.default maybePreference
    in
    ( { session = Pages.Session key url
      , userPreferences = userPreference
      , pageModel = Pages.pageOf url userPreference
      , toasts = Lib.Toast.init
      }
    , Out.Commands.send <| Out.Commands.ChangeVolume userPreference.volume
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | LoginMsg Login.Msg
    | MobMsg Mob.Main.Msg
    | Batch (List Msg)
    | ToastMsg Lib.Toast.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model.pageModel, msg ) of
        ( _, Batch messages ) ->
            Lib.BatchMsg.update messages model update

        ( _, LinkClicked urlRequest ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Pages.pushUrl url model.session )

                Browser.External href ->
                    ( model, Nav.load href )

        ( _, UrlChanged url ) ->
            let
                ( session, pageModel ) =
                    Pages.urlChanged url model.session model.userPreferences
            in
            ( { model | session = session, pageModel = pageModel }
            , Cmd.none
            )

        ( Pages.LoginModel loginModel, LoginMsg loginMsg ) ->
            Login.update loginModel loginMsg model.session.key
                |> Tuple.mapBoth
                    (\it -> { model | pageModel = Pages.LoginModel it })
                    (Cmd.map LoginMsg)

        ( Pages.MobModel mobModel, MobMsg mobMsg ) ->
            Mob.Main.update mobMsg mobModel
                |> Tuple.mapBoth
                    (\it -> { model | pageModel = Pages.MobModel it })
                    (Cmd.map MobMsg)

        ( _, ToastMsg toastMsg ) ->
            Lib.Toast.update toastMsg model.toasts
                |> Tuple.mapBoth
                    (\it -> { model | toasts = it })
                    (Cmd.map ToastMsg)

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Mob.Main.subscriptions |> Sub.map MobMsg
        , Out.Events.events (dispatch eventsMapping)
        ]


dispatch : EventsMapping Msg -> Out.Events.Event -> Msg
dispatch mapping event =
    Batch <| EventsMapping.dispatch event mapping


eventsMapping : EventsMapping Msg
eventsMapping =
    EventsMapping.batch
        [ EventsMapping.map MobMsg Mob.Main.eventsMapping
        , EventsMapping.map ToastMsg Lib.Toast.eventsMapping
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = pageTitle model
    , body =
        [ pageBody model
        , Lib.Toast.view model.toasts |> Html.map ToastMsg
        ]
    }


pageTitle : Model -> String
pageTitle model =
    case model.pageModel of
        Pages.LoginModel _ ->
            Login.title

        Pages.MobModel mobModel ->
            Mob.Main.pageTitle mobModel


pageBody : Model -> Html Msg
pageBody model =
    case model.pageModel of
        Pages.LoginModel loginModel ->
            Login.view loginModel |> Html.map LoginMsg

        Pages.MobModel mobModel ->
            Mob.Main.view mobModel model.session.url |> Html.map MobMsg
