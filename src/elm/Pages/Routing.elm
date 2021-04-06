module Routing exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.Toaster exposing (Toasts)
import Pages.Login
import Pages.Mob.Main
import Url
import Url.Parser as UrlParser exposing ((</>), Parser, map, oneOf, s, top)
import UserPreferences


type PageModel
    = LoginModel Pages.Login.Model
    | MobModel Pages.Mob.Main.Model


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
    = LoginMsg Pages.Login.Msg
    | MobMsg Pages.Mob.Main.Msg


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
                        Pages.Login.init
                            |> Tuple.mapBoth LoginModel (Cmd.map LoginMsg)

                    Mob name ->
                        Pages.Mob.Main.init name userPreferences
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
            Pages.Login.update loginModel loginMsg session.key
                |> (\( model, cmd ) ->
                        ( { session | pageModel = LoginModel model }
                        , Cmd.map LoginMsg cmd
                        , []
                        )
                   )

        ( MobModel mobModel, MobMsg mobMsg ) ->
            let
                (mob, mobCommand) =
                    Pages.Mob.Main.update mobMsg mobModel
            in
            ( { session | pageModel = MobModel mob }
            , Cmd.map MobMsg mobCommand
            , []
            )

        _ ->
            ( session, Cmd.none, [] )


subscriptions : Sub Msg
subscriptions =
    Pages.Mob.Main.subscriptions |> Sub.map MobMsg


view : Session -> Browser.Document Msg
view model =
    case model.pageModel of
        LoginModel loginModel ->
            Pages.Login.view loginModel
                |> documentMap LoginMsg

        MobModel mobModel ->
            Pages.Mob.Main.view mobModel model.url
                |> documentMap MobMsg


documentMap : (a -> b) -> Browser.Document a -> Browser.Document b
documentMap f document =
    { title = document.title, body = document.body |> (List.map <| Html.map f) }
