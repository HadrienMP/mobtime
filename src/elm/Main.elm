port module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (div, h1)
import Html.Attributes exposing (id)
import Identity
import Json.Decode
import Json.Encode
import Mob exposing (MobberId)
import Page.Join exposing (Model)
import Page.Mob
import Random
import Routes exposing (Route)
import Session exposing (Session)
import Sse exposing (EventKind)
import Tools exposing (fold, uuid)
import Url
import Url.Parser as Parser exposing ((</>), Parser)
import Validation exposing (ValidationResult)


-- MAIN

main : Program String Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }

port messageReceiver : ((EventKind, Json.Decode.Value) -> msg) -> Sub msg
port store : Json.Encode.Value -> Cmd msg


-- MODEL

type PageModel
    = JoinModel Page.Join.Model
    | MobModel Page.Mob.Model

type alias Model =
  { session : Session
  , page : PageModel
  }


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model : Model
        model =
            { session = (Session key url Identity.empty)
            , page = (JoinModel { mobName = Validation.initial, stats = Nothing })
            }
    in
       Parser.parse Routes.parser url
       |> Maybe.map (routeUpdate model)
       |> Maybe.map (Tuple.mapSecond (\cmd -> Cmd.batch [cmd, Random.generate (GotIdentityMsg << Identity.IdGenerated) uuid]))
       |> Maybe.withDefault (model, Random.generate (GotIdentityMsg << Identity.IdGenerated) uuid)

-- UPDATE

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | UnknownSseEvent

  | GotJoinMsg Page.Join.Msg
  | GotMobMsg Page.Mob.Msg
  | GotMobbersMsg Page.Mob.Msg
  | GotIdentityMsg Identity.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (msg, model.page) of
        (LinkClicked urlRequest, _) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        (UrlChanged url, _) ->
            Parser.parse Routes.parser url
            |> Maybe.map (routeUpdate model)
            |> Maybe.withDefault (model, Cmd.none)

        (GotIdentityMsg subMsg, _) ->
            Identity.update model.session.identity subMsg store
            |> Tuple.mapBoth
                (\identity -> { model | session = Session.updateIdentity identity model.session })
                (Cmd.map GotIdentityMsg)

        (GotJoinMsg subMsg, JoinModel form) ->
            Page.Join.update model.session form subMsg JoinModel GotJoinMsg
            |> Tuple.mapFirst (\f -> { model | page = f })

        (GotMobMsg subMsg, MobModel subModel) ->
            Page.Mob.update subModel subMsg model.session
            |> Tuple.mapBoth
                (\f -> { model | page = MobModel f })
                (Cmd.map GotMobMsg)

        (_, _) ->
            (model, Cmd.none)

routeUpdate : Model -> Route -> (Model, Cmd Msg)
routeUpdate model route =
    case route of
        Routes.Login ->
            Page.Join.init
            |> Tuple.mapBoth
                (\subModel -> { model | page = subModel |> JoinModel })
                (Cmd.map GotJoinMsg)
        Routes.Timer mob ->
            Page.Mob.init mob model.session
            |> Tuple.mapBoth
                (\subModel -> { model | page = subModel |> MobModel })
                (Cmd.map GotMobMsg)
        Routes.Mobbers mob ->
            Page.Mob.init mob model.session
            |> Tuple.mapBoth
                (\subModel -> { model | page = subModel |> MobModel })
                (Cmd.map GotMobbersMsg)

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ = messageReceiver handleEvent

handleEvent : (EventKind, Json.Decode.Value) -> Msg
handleEvent event =
    Sse.through dispatch event
    |> fold (\e -> Debug.log e UnknownSseEvent) identity

dispatch : Sse.Event -> Result String Msg
dispatch event =
    case event.kind of
        "mobberAdded" ->
            Sse.decodeData mobberEventDecoder event
            |> Result.map Page.Mob.MobberAdded
            |> Result.map GotMobMsg
        "mobberUpdated" ->
            Sse.decodeData mobberEventDecoder event
            |> Result.map Page.Mob.MobberAdded
            |> Result.map GotMobMsg
        "mobberLeft" ->
            Sse.decodeData mobberEventDecoder event
            |> Result.map Page.Mob.MobberLeft
            |> Result.map GotMobMsg
        _ -> Err ("Unknown event type: " ++ event.kind)

mobberEventDecoder =
    Json.Decode.map2
        (\a b -> (a,b))
        (Json.Decode.field "mobber" Mob.mobberDecoder)
        (Json.Decode.field "mobbers" Mob.mobbersDecoder)

-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        JoinModel subModel -> Page.Join.view subModel model.session.identity GotJoinMsg GotIdentityMsg
        MobModel subModel -> Page.Mob.view subModel model.session GotMobMsg GotIdentityMsg