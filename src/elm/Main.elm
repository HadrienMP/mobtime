module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Lib.BatchMsg
import Lib.Toast
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
    , toasts : Lib.Toast.Toasts
    }


init : Maybe UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init maybePreference url key =
    let
        userPreference =
            Maybe.withDefault UserPreferences.default maybePreference

        ( session, command ) =
            Pages.init key url userPreference
    in
    ( { session = session
      , toasts = Lib.Toast.init
      }
    , command |> Cmd.map PageMsg
    )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | PageMsg Pages.Msg
    | Batch (List Msg)
    | ToastMsg Lib.Toast.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Batch messages ->
            Lib.BatchMsg.update messages model update

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Pages.pushUrl url model.session )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            Pages.urlChanged url model.session
                |> Tuple.mapBoth
                    (\session -> { model | session = session })
                    (Cmd.map PageMsg)

        PageMsg pageMsg ->
            let
                ( session, command, toasts ) =
                    Pages.update pageMsg model.session

                ( allToasts, commands ) =
                    Lib.Toast.add toasts model.toasts
            in
            ( { model
                | session = session
                , toasts = allToasts
              }
            , Cmd.batch <| (command |> Cmd.map PageMsg) :: (commands |> List.map (Cmd.map ToastMsg))
            )

        ToastMsg toastMsg ->
            Lib.Toast.update toastMsg model.toasts
                |> Tuple.mapBoth
                    (\it -> { model | toasts = it })
                    (Cmd.map ToastMsg)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Pages.subscriptions |> Sub.map PageMsg
        , Out.Events.events (dispatch eventsMapping)
        ]


dispatch : EventsMapping Msg -> Out.Events.Event -> Msg
dispatch mapping event =
    Batch <| EventsMapping.dispatch event mapping


eventsMapping : EventsMapping Msg
eventsMapping =
    EventsMapping.batch
        [ EventsMapping.map PageMsg Pages.eventsMapping
        , EventsMapping.map ToastMsg Lib.Toast.eventsMapping
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = Pages.pageTitle model.session
    , body =
        [ Pages.pageBody model.session |> Html.map PageMsg
        , Lib.Toast.view model.toasts |> Html.map ToastMsg
        ]
    }
