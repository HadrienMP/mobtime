port module Shared exposing (Msg(..), Shared, init, pushUrl, subscriptions, toast, update, withUrl)

import Browser
import Browser.Navigation as Nav
import Components.Socket.Socket as Socket
import Effect exposing (Effect)
import Js.Events
import Js.EventsMapping exposing (EventsMapping)
import Json.Decode as Decode
import Lib.Konami exposing (Konami)
import Lib.Toaster exposing (Toast, Toasts)
import Model.MobName exposing (MobName)
import Routing
import Url
import UserPreferences


port soundOn : (String -> msg) -> Sub msg



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
    , soundOn : Bool
    }


withUrl : Url.Url -> Shared -> Shared
withUrl url shared =
    { shared | url = url }


init :
    { key : Nav.Key
    , url : Url.Url
    , jsonPreferences : Decode.Value
    , mob : Maybe MobName
    }
    -> ( Shared, Cmd Msg )
init { key, url, jsonPreferences, mob } =
    let
        ( socket, socketCmd ) =
            Socket.init |> Tuple.mapSecond (Cmd.map SocketMsg)

        ( preferences, preferencesCommand ) =
            UserPreferences.init jsonPreferences
    in
    ( { socket = socket
      , toasts = Lib.Toaster.init
      , key = key
      , url = url
      , preferences = preferences
      , mob = mob
      , devMode = False
      , konami = Lib.Konami.init
      , soundOn = False
      }
    , Cmd.batch
        [ socketCmd
        , preferencesCommand
        ]
    )



-- Update


type Msg
    = Toast Lib.Toaster.Msg
    | SocketMsg Socket.Msg
    | LinkClicked Browser.UrlRequest
    | KonamiMsg Lib.Konami.Msg
    | Batch (List Msg)
    | PreferencesMsg UserPreferences.Msg
    | SoundOn
    | JoinMob MobName


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

        PreferencesMsg subMsg ->
            UserPreferences.update subMsg shared.preferences
                |> Tuple.mapBoth
                    (\volume -> { shared | preferences = volume })
                    (Cmd.map PreferencesMsg)

        Batch _ ->
            ( shared, Cmd.none )

        SoundOn ->
            ( { shared | soundOn = True }, Cmd.none )

        JoinMob mob ->
            ( { shared | mob = Just mob }, Cmd.none )


toast : Toast -> Effect Msg msg
toast =
    Effect.fromShared << Toast << Lib.Toaster.Add


pushUrl : Shared -> Routing.Page -> Effect Msg msg
pushUrl shared =
    Routing.toUrl
        >> Nav.pushUrl shared.key
        >> Effect.fromCmd



-- Subscriptions


subscriptions : Shared -> Sub Msg
subscriptions shared =
    Sub.batch
        [ Js.Events.events (dispatch jsEventsMapping)
        , Socket.subscriptions shared.socket
            |> Sub.map SocketMsg
        , Lib.Konami.subscriptions shared.konami
            |> Sub.map KonamiMsg
        , soundOn <| always SoundOn
        ]


dispatch : EventsMapping Msg -> Js.Events.Event -> Msg
dispatch mapping event =
    Batch <| Js.EventsMapping.dispatch event mapping


jsEventsMapping : EventsMapping Msg
jsEventsMapping =
    Js.EventsMapping.map Toast Lib.Toaster.jsEventMapping
