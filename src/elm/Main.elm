module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Js.Commands
import Lib.DocumentExtras
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
    }


init : UserPreferences.Model -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init preferences url key =
    loadPage url preferences
        |> Tuple.mapBoth
            (\page ->
                { key = key
                , url = url
                , page = page
                , preferences = preferences
                }
            )
            (\command ->
                Cmd.batch
                    [ Task.perform TimePassed Time.now
                    , Js.Commands.send <| Js.Commands.ChangeVolume preferences.volume
                    , command
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
                |> Tuple.mapFirst (\page -> { model | page = page })

        ( GotLoginMsg subMsg, LoginModel subModel ) ->
            Pages.Login.update subModel subMsg model.key
                |> Tuple.mapBoth
                    (\mob -> { model | page = LoginModel mob })
                    (Cmd.map GotLoginMsg)

        ( GotMobMsg subMsg, MobModel subModel ) ->
            Pages.Mob.Main.update subMsg subModel
                |> Tuple.mapBoth
                    (\mob -> { model | page = MobModel mob })
                    (Cmd.map GotMobMsg)

        ( TimePassed now, MobModel subModel ) ->
            Pages.Mob.Main.timePassed now subModel
                |> Tuple.mapBoth
                    (\mob -> { model | page = MobModel mob })
                    (Cmd.map GotMobMsg)

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Pages.Mob.Main.subscriptions |> Sub.map GotMobMsg
        , Time.every 500 TimePassed
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        LoginModel sub ->
            Pages.Login.view sub
                |> Lib.DocumentExtras.map GotLoginMsg

        MobModel sub ->
            Pages.Mob.Main.view sub model.url
                |> Lib.DocumentExtras.map GotMobMsg
