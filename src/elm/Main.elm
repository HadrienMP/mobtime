module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, h2, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Html.Styled
import Js.Commands
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.BatchMsg
import Lib.DocumentExtras
import Lib.Icons.Ion
import Lib.Toaster as Toaster exposing (Toasts)
import Lib.UpdateResult as UpdateResult exposing (UpdateResult)
import Pages.Home
import Pages.Mob
import Routing
import Socket
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


type Page
    = Home Pages.Home.Model
    | Mob Pages.Mob.Model


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , page : Page
    , preferences : UserPreferences.Model
    , toasts : Toasts
    , displayModal : Bool
    , socket : Socket.Model
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init preferences url key =
    let
        ( page, pageCommand ) =
            loadPage url preferences

        ( socket, socketCommand ) =
            Socket.init
    in
    ( { key = key
      , url = url
      , page = page
      , preferences = preferences
      , toasts = []
      , displayModal =
            case page of
                Home _ ->
                    False

                Mob _ ->
                    True
      , socket = socket
      }
    , Cmd.batch
        [ Js.Commands.send <| Js.Commands.ChangeVolume preferences.volume
        , pageCommand
        , socketCommand |> Cmd.map SocketMsg
        ]
    )


loadPage : Url.Url -> UserPreferences.Model -> ( Page, Cmd Msg )
loadPage url preferences =
    case Routing.toPage url of
        Routing.Login ->
            Pages.Home.init
                |> Tuple.mapBoth
                    Home
                    (Cmd.map GotHomeMsg)

        Routing.Mob mobName ->
            Pages.Mob.init mobName preferences
                |> Tuple.mapBoth
                    Mob
                    (Cmd.map GotMobMsg)



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotMobMsg Pages.Mob.Msg
    | GotHomeMsg Pages.Home.Msg
    | GotToastMsg Toaster.Msg
    | Batch (List Msg)
    | HideModal
    | SocketMsg Socket.Msg


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

        ( GotHomeMsg subMsg, Home subModel ) ->
            Pages.Home.update subModel subMsg model.key
                |> UpdateResult.map Home GotHomeMsg
                |> handleToasts model
                |> toElm model

        ( GotMobMsg subMsg, Mob subModel ) ->
            Pages.Mob.update subMsg subModel
                |> UpdateResult.map Mob GotMobMsg
                |> handleToasts model
                |> toElm model

        ( GotToastMsg subMsg, _ ) ->
            Toaster.update subMsg model.toasts
                |> Tuple.mapBoth
                    (\toasts -> { model | toasts = toasts })
                    (Cmd.map GotToastMsg)

        ( Batch messages, _ ) ->
            Lib.BatchMsg.update messages model update

        ( HideModal, _ ) ->
            ( { model | displayModal = False }
            , Cmd.none
            )

        ( SocketMsg subMsg, _ ) ->
            Socket.update subMsg model.socket
                |> Tuple.mapBoth
                    (\updated -> { model | socket = updated })
                    (Cmd.map SocketMsg)

        _ ->
            ( model, Cmd.none )


toElm : Model -> UpdateResult Page Msg -> ( Model, Cmd Msg )
toElm model updateResult =
    ( { model | page = updateResult.model, toasts = updateResult.toasts }, updateResult.command )


handleToasts : Model -> UpdateResult Page Msg -> UpdateResult Page Msg
handleToasts model result =
    let
        ( allToasts, toastCommands ) =
            Toaster.add result.toasts model.toasts

        command =
            toastCommands
                |> List.map (Cmd.map GotToastMsg)
                |> (::) result.command
                |> Cmd.batch
    in
    UpdateResult result.model command allToasts


toast : Toaster.Toast -> Model -> ( Model, Cmd Msg )
toast toToast model =
    let
        ( toasts, commands ) =
            Toaster.add [ toToast ] model.toasts
    in
    ( { model | toasts = toasts }
    , commands
        |> List.map (Cmd.map GotToastMsg)
        |> Cmd.batch
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model.page of
            Home _ ->
                Sub.none

            Mob mobModel ->
                Pages.Mob.subscriptions mobModel |> Sub.map GotMobMsg
        , Js.Events.events (dispatch jsEventsMapping)
        , Socket.subscriptions model.socket
            |> Sub.map SocketMsg
        ]


dispatch : EventsMapping Msg -> Js.Events.Event -> Msg
dispatch mapping event =
    Batch <| EventsMapping.dispatch event mapping


jsEventsMapping : EventsMapping Msg
jsEventsMapping =
    EventsMapping.batch
        [ EventsMapping.map GotMobMsg Pages.Mob.jsEventMapping
        , EventsMapping.map GotToastMsg Toaster.jsEventMapping
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        doc =
            case model.page of
                Home sub ->
                    Pages.Home.view sub
                        |> Lib.DocumentExtras.map GotHomeMsg

                Mob sub ->
                    Pages.Mob.view sub model.url
                        |> Lib.DocumentExtras.map GotMobMsg
    in
    { title = doc.title
    , body =
        [ Html.Styled.toUnstyled <|
            Html.Styled.div []
                [ Html.Styled.div []
                    (doc.body
                        ++ soundModal model
                        ++ [ Toaster.view model.toasts |> Html.map GotToastMsg ]
                        |> List.map Html.Styled.fromUnstyled
                    )
                , Socket.view model.socket
                ]
        ]
    }


soundModal : Model -> List (Html Msg)
soundModal model =
    if model.displayModal then
        [ div
            [ id "modal-container", onClick HideModal ]
            [ div [ id "modal" ]
                [ h2 [] [ text "Welcome to Mobtime !" ]
                , button
                    [ class "labelled-icon-button"
                    , onClick <| HideModal
                    ]
                    [ Lib.Icons.Ion.paperAirplane
                    , text "Let's go!"
                    ]
                ]
            ]
        ]

    else
        []
