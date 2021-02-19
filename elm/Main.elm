module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Interface.Commands
import Interface.Events
import Json.Decode
import Login
import Mob.Main
import Mob.Sound.Main
import Pages
import Url
import UserPreferences



-- MAIN


main : Program UserPreferences.Model Model Msg
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
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init userPreferences url key =
    ( { session = Pages.Session key url
      , userPreferences = userPreferences
      , pageModel = Pages.pageOf url userPreferences
      }
    , Interface.Commands.send <| Interface.Commands.ChangeVolume userPreferences.volume
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | LoginMsg Login.Msg
    | MobMsg Mob.Main.Msg
    | UnknownEvent Interface.Events.Event


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model.pageModel, msg ) of
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

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Mob.Main.subscriptions |> Sub.map MobMsg
        , Interface.Events.events <| eventToMsg <| Interface.Events.map MobMsg Mob.Main.events
        ]


eventToMsg : List (Interface.Events.EventMsg Msg) -> Interface.Events.Event -> Msg
eventToMsg map event =
    List.filter (\( name, _ ) -> name == event.name) map
        |> List.head
        |> Maybe.map (\( _, msg ) -> msg event.value)
        |> Maybe.withDefault (UnknownEvent event)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = pageTitle model
    , body = [ pageBody model ]
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
