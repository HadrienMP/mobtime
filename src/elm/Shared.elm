module Shared exposing (..)

import Browser
import Browser.Navigation as Nav
import Js.Commands
import Js.Events
import Js.EventsMapping exposing (EventsMapping)
import Lib.Konami exposing (Konami)
import Lib.Toaster exposing (Toasts)
import Model.MobName exposing (MobName)
import Socket
import Url
import UserPreferences



-- Init


type alias Shared =
    { socket : Socket.Model
    , toasts : Toasts
    , key : Nav.Key
    , url : Url.Url
    , preferences : UserPreferences.Model
    , mob : Maybe MobName
    , devMode : Bool
    , konami : Konami
    }


withUrl : Url.Url -> Shared -> Shared
withUrl url shared =
    { shared | url = url }


init :
    { key : Nav.Key
    , url : Url.Url
    , preferences : UserPreferences.Model
    , mob : Maybe MobName
    }
    -> ( Shared, Cmd Msg )
init { key, url, preferences, mob } =
    let
        ( socket, socketCmd ) =
            Socket.init |> Tuple.mapSecond (Cmd.map SocketMsg)
    in
    ( { socket = socket
      , toasts = Lib.Toaster.init
      , key = key
      , url = url
      , preferences = preferences
      , mob = mob
      , devMode = False
      , konami = Lib.Konami.init
      }
    , Cmd.batch
        [ socketCmd
        , Js.Commands.ChangeVolume preferences.volume
            |> Js.Commands.send
        ]
    )



-- Update


type Msg
    = Toast Lib.Toaster.Msg
    | SocketMsg Socket.Msg
    | LinkClicked Browser.UrlRequest
    | KonamiMsg Lib.Konami.Msg
    | Batch (List Msg)
    | VolumeChanged Int


update : Msg -> Shared -> ( Shared, Cmd Msg )
update msg shared =
    case msg of
        Batch msgs ->
            msgs
                |> List.foldl
                    (\nextMsg ( model, cmds ) -> update_ nextMsg model |> Tuple.mapSecond (\cmd -> cmd :: cmds))
                    ( shared, [] )
                |> Tuple.mapSecond Cmd.batch

        _ ->
            update_ msg shared


update_ : Msg -> Shared -> ( Shared, Cmd Msg )
update_ msg shared =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( shared, Nav.pushUrl shared.key (Url.toString url) )

                Browser.External href ->
                    ( shared, Nav.load href )

        SocketMsg subMsg ->
            Socket.update shared.mob subMsg shared.socket
                |> Tuple.mapBoth
                    (\updated -> { shared | socket = updated })
                    (Cmd.map SocketMsg)

        Toast subMsg ->
            Lib.Toaster.update subMsg shared.toasts
                |> Tuple.mapBoth
                    (\toasts -> { shared | toasts = toasts })
                    (Cmd.map Toast)

        KonamiMsg subMsg ->
            let
                ( updated, cmd ) =
                    Lib.Konami.update subMsg shared.konami
            in
            ( { shared
                | devMode = Lib.Konami.isOn updated
                , konami = updated
              }
            , cmd |> Cmd.map KonamiMsg
            )

        VolumeChanged volume ->
            ( { shared | preferences = { volume = volume } }, Cmd.none )

        _ ->
            ( shared, Cmd.none )


toast : Toasts -> Shared -> ( Shared, Cmd Msg )
toast toasts shared =
    let
        ( allToasts, toastCommands ) =
            Lib.Toaster.add toasts shared.toasts
    in
    ( { shared | toasts = allToasts }
    , toastCommands
        |> List.map (Cmd.map Toast)
        |> Cmd.batch
    )



-- Subscriptions


subscriptions : Shared -> Sub Msg
subscriptions shared =
    Sub.batch
        [ Js.Events.events (dispatch jsEventsMapping)
        , Socket.subscriptions shared.socket
            |> Sub.map SocketMsg
        , Lib.Konami.subscriptions shared.konami
            |> Sub.map KonamiMsg
        ]


dispatch : EventsMapping Msg -> Js.Events.Event -> Msg
dispatch mapping event =
    Batch <| Js.EventsMapping.dispatch event mapping


jsEventsMapping : EventsMapping Msg
jsEventsMapping =
    Js.EventsMapping.map Toast Lib.Toaster.jsEventMapping
