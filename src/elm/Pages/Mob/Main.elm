module Pages.Mob.Main exposing
    ( Model
    , Msg(..)
    , Page(..)
    , init
    , jsEventMapping
    , subscriptions
    , update
    , view
    )

import Components.Socket.Socket
import Effect exposing (Effect)
import Js.EventsMapping
import Lib.Duration
import Model.Clock
import Model.Events
import Model.Mob
import Model.MobName
import Pages.Mob
import Pages.Mob.Settings.Page
import Routing
import Shared exposing (Shared)
import Time
import View exposing (View)



-- Init


type Page
    = Home Pages.Mob.Model
    | Settings


type alias Model =
    { mob : Model.Mob.Mob
    , page : Page
    }


init : Shared -> Routing.MobRoute -> ( Model, Effect Shared.Msg Msg )
init shared route =
    let
        ( page, effect ) =
            initSubPage route shared
    in
    ( { mob = Model.Mob.init route.name
      , page = page
      }
    , Effect.batch
        [ effect
        , Effect.fromCmd <| Components.Socket.Socket.joinRoom <| Model.MobName.print route.name
        ]
    )


initSubPage : Routing.MobRoute -> Shared -> ( Page, Effect Shared.Msg Msg )
initSubPage route shared =
    case route.subRoute of
        Routing.MobHome ->
            Pages.Mob.init shared route.name
                |> Tuple.mapBoth Home (Effect.map HomeMsg)

        Routing.MobSettings ->
            ( Settings, Effect.none )



-- Update


type Msg
    = HomeMsg Pages.Mob.Msg
    | SettingsMsg Pages.Mob.Settings.Page.Msg
    | ReceivedEvent Model.Events.Event
    | ReceivedHistory (List Model.Events.Event)
    | Tick Time.Posix
    | RouteChanged Routing.MobRoute


update : Shared -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared msg model =
    case ( msg, model.page ) of
        ( RouteChanged route, _ ) ->
            initSubPage route shared
                |> Tuple.mapFirst
                    (\next -> { model | page = next })

        ( HomeMsg subMsg, Home subModel ) ->
            Pages.Mob.update shared model.mob subMsg subModel
                |> Tuple.mapBoth
                    (\next -> { model | page = Home next })
                    (Effect.map HomeMsg)

        ( SettingsMsg subMsg, Settings ) ->
            Pages.Mob.Settings.Page.update shared subMsg model.mob
                |> Tuple.mapBoth
                    (\next -> { model | mob = next })
                    (Effect.map SettingsMsg)

        ( ReceivedEvent event, _ ) ->
            let
                ( updated, command ) =
                    Model.Mob.evolve event model.mob
            in
            ( { model | mob = updated }
            , Effect.fromCmd command
            )

        ( ReceivedHistory eventsResults, _ ) ->
            let
                ( updated, command ) =
                    Model.Mob.evolveMany eventsResults model.mob
            in
            ( { model | mob = updated }
            , Effect.fromCmd command
            )

        ( Tick now, _ ) ->
            let
                timePassedResult =
                    Model.Mob.timePassed now model.mob

                ( nextPage, pageEffect ) =
                    case model.page of
                        Home subModel ->
                            Pages.Mob.update
                                shared
                                model.mob
                                (Pages.Mob.TimePassed now timePassedResult)
                                subModel
                                |> Tuple.mapBoth
                                    Home
                                    (Effect.map HomeMsg)

                        page ->
                            ( page, Effect.none )
            in
            ( { model
                | page = nextPage
                , mob = timePassedResult.updated
              }
            , pageEffect
            )

        _ ->
            ( model, Effect.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Model.Events.receiveOne <| Model.Events.fromJson >> ReceivedEvent
        , Model.Events.receiveHistory <| List.map Model.Events.fromJson >> ReceivedHistory
        , case model.page of
            Home subModel ->
                Pages.Mob.subscriptions subModel
                    |> Sub.map HomeMsg

            Settings ->
                Pages.Mob.Settings.Page.subscriptions model.mob
                    |> Sub.map SettingsMsg
        , case ( Model.Clock.isOn model.mob.clock, Model.Clock.isOn model.mob.pomodoro ) of
            ( True, _ ) ->
                Pages.Mob.turnRefreshRate
                    |> (Lib.Duration.toMillis >> toFloat)
                    |> (\duration -> Time.every duration Tick)

            ( False, True ) ->
                Time.every 2000 Tick

            _ ->
                Sub.none
        ]



-- TODO get rid of me !


jsEventMapping : Js.EventsMapping.EventsMapping Msg
jsEventMapping =
    Pages.Mob.jsEventMapping |> Js.EventsMapping.map HomeMsg



-- View


view : Shared -> Model -> View Msg
view shared model =
    let
        subView =
            case model.page of
                Home subModel ->
                    Pages.Mob.view shared model.mob subModel
                        |> View.map HomeMsg

                Settings ->
                    Pages.Mob.Settings.Page.view model.mob
                        |> View.map SettingsMsg
    in
    { title =
        case subView.title of
            "" ->
                Model.MobName.print model.mob.name

            title ->
                title ++ " | " ++ Model.MobName.print model.mob.name
    , modal =
        subView.modal
    , body = subView.body
    }
