module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.BatchMsg
import Lib.DocumentExtras
import Lib.Toaster exposing (Toasts)
import Lib.UpdateResult exposing (UpdateResult)
import Pages.Login
import Pages.Mob.Main
import Pages.Routing
import Task
import Time
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


type PageModel
    = LoginModel Pages.Login.Model
    | MobModel Pages.Mob.Main.Model


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : PageModel
    , preferences : UserPreferences.Model
    , toasts : Toasts
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init preferences url key =
    let
        ( page, pageCommand ) =
            loadPage url preferences
    in
    ( { key = key
      , url = url
      , page = page
      , preferences = preferences
      , toasts = []
      }
    , Cmd.batch
        [ Task.perform TimePassed Time.now
        , Js.Commands.send <| Js.Commands.ChangeVolume preferences.volume
        , pageCommand
        ]
    )


loadPage : Url.Url -> UserPreferences.Model -> ( PageModel, Cmd Msg )
loadPage url preferences =
    case Pages.Routing.toPage url of
        Pages.Routing.Login ->
            Pages.Login.init
                |> Tuple.mapBoth
                    LoginModel
                    (Cmd.map GotLoginMsg)

        Pages.Routing.Mob mobName ->
            Pages.Mob.Main.init mobName preferences
                |> Tuple.mapBoth
                    MobModel
                    (Cmd.map GotMobMsg)



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | TimePassed Time.Posix
    | GotMobMsg Pages.Mob.Main.Msg
    | GotLoginMsg Pages.Login.Msg
    | GotToastMsg Lib.Toaster.Msg
    | Batch (List Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            loadPage url model.preferences
                |> Tuple.mapFirst (\page -> { model | page = page, url = url })

        ( GotLoginMsg subMsg, LoginModel subModel ) ->
            let
                login =
                    Pages.Login.update subModel subMsg model.key

                ( allToasts, commands ) =
                    Lib.Toaster.add login.toasts model.toasts
                        |> Tuple.mapSecond (List.map (Cmd.map GotToastMsg))
            in
            ( { model
                | page = LoginModel login.model
                , toasts = allToasts
              }
            , Cmd.batch
                (Cmd.map GotLoginMsg login.command
                    :: commands
                )
            )

        ( GotMobMsg subMsg, MobModel subModel ) ->
            let
                mob =
                    Pages.Mob.Main.update subMsg subModel

                ( allToasts, commands ) =
                    Lib.Toaster.add mob.toasts model.toasts
                        |> Tuple.mapSecond (List.map (Cmd.map GotToastMsg))
            in
            ( { model
                | page = MobModel mob.model
                , toasts = allToasts
              }
            , Cmd.batch
                (Cmd.map GotMobMsg mob.command
                    :: commands
                )
            )

        ( TimePassed now, MobModel subModel ) ->
            Pages.Mob.Main.timePassed now subModel
                |> Tuple.mapBoth
                    (\mob -> { model | page = MobModel mob })
                    (Cmd.map GotMobMsg)

        ( GotToastMsg subMsg, _ ) ->
            Lib.Toaster.update subMsg model.toasts
                |> Tuple.mapBoth
                    (\toasts -> { model | toasts = toasts })
                    (Cmd.map GotToastMsg)

        ( Batch messages, _ ) ->
            Lib.BatchMsg.update messages model update

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Pages.Mob.Main.subscriptions |> Sub.map GotMobMsg
        , Time.every 500 TimePassed
        , Js.Events.events (dispatch jsEventsMapping)
        ]


dispatch : EventsMapping Msg -> Js.Events.Event -> Msg
dispatch mapping event =
    Batch <| EventsMapping.dispatch event mapping


jsEventsMapping : EventsMapping Msg
jsEventsMapping =
    EventsMapping.batch
        [ EventsMapping.map GotMobMsg Pages.Mob.Main.jsEventMapping
        , EventsMapping.map GotToastMsg Lib.Toaster.jsEventMapping
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        doc =
            case model.page of
                LoginModel sub ->
                    Pages.Login.view sub
                        |> Lib.DocumentExtras.map GotLoginMsg

                MobModel sub ->
                    Pages.Mob.Main.view sub model.url
                        |> Lib.DocumentExtras.map GotMobMsg
    in
    { title = doc.title
    , body = doc.body ++ [ Lib.Toaster.view model.toasts |> Html.map GotToastMsg ]
    }
