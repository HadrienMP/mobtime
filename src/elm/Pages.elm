module Pages exposing (..)

import Browser.Navigation as Nav
import Html exposing (Html)
import Lib.Toast exposing (Toasts)
import Login
import Mob.Main
import Out.EventsMapping as EventsMapping exposing (EventsMapping)
import Url
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)
import UserPreferences


type PageModel
    = LoginModel Login.Model
    | MobModel Mob.Main.Model


type Page
    = Login
    | Mob String


type alias Session =
    { key : Nav.Key
    , url : Url.Url
    , pageModel : PageModel
    , userPreferences : UserPreferences.Model
    }


type Msg
    = LoginMsg Login.Msg
    | MobMsg Mob.Main.Msg


pushUrl : Url.Url -> Session -> Cmd msg
pushUrl url session =
    Nav.pushUrl session.key (Url.toString url)


urlChanged : Url.Url -> Session -> ( Session, Cmd Msg )
urlChanged url session =
    init session.key url session.userPreferences


init : Nav.Key -> Url.Url -> UserPreferences.Model -> ( Session, Cmd Msg )
init key url userPreferences =
    let
        ( page, command ) =
            initPage url userPreferences
    in
    ( Session key url page userPreferences, command )


initPage : Url.Url -> UserPreferences.Model -> ( PageModel, Cmd Msg )
initPage url userPreferences =
    UrlParser.parse route url
        |> Maybe.withDefault Login
        |> (\page ->
                case page of
                    Login ->
                        Login.init
                            |> Tuple.mapBoth LoginModel (Cmd.map LoginMsg)

                    Mob name ->
                        Mob.Main.init name userPreferences
                            |> Tuple.mapBoth MobModel (Cmd.map MobMsg)
           )


route : Parser (Page -> c) c
route =
    oneOf
        [ map Login top
        , map Mob (s "mob" </> UrlParser.string)
        ]


update : Msg -> Session -> ( Session, Cmd Msg, Toasts )
update msg session =
    case ( session.pageModel, msg ) of
        ( LoginModel loginModel, LoginMsg loginMsg ) ->
            Login.update loginModel loginMsg session.key
                |> (\( model, cmd ) ->
                        ( { session | pageModel = LoginModel model }
                        , Cmd.map LoginMsg cmd
                        , []
                        )
                   )

        ( MobModel mobModel, MobMsg mobMsg ) ->
            let
                mobResult =
                    Mob.Main.update mobMsg mobModel
            in
            ( { session | pageModel = MobModel mobResult.model }
            , Cmd.map MobMsg mobResult.command
            , mobResult.toast
            )

        _ ->
            ( session, Cmd.none, [] )


subscriptions : Sub Msg
subscriptions =
    Mob.Main.subscriptions |> Sub.map MobMsg


eventsMapping : EventsMapping Msg
eventsMapping =
    EventsMapping.map MobMsg Mob.Main.eventsMapping


pageTitle : Session -> String
pageTitle model =
    case model.pageModel of
        LoginModel _ ->
            Login.title

        MobModel mobModel ->
            Mob.Main.pageTitle mobModel


pageBody : Session -> Html Msg
pageBody model =
    case model.pageModel of
        LoginModel loginModel ->
            Login.view loginModel |> Html.map LoginMsg

        MobModel mobModel ->
            Mob.Main.view mobModel model.url |> Html.map MobMsg
