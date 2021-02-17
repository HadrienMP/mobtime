module Pages exposing (..)

import Browser.Navigation as Nav
import Login
import Mob.Main
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
    }


pushUrl : Url.Url -> Session -> Cmd msg
pushUrl url session =
    Nav.pushUrl session.key (Url.toString url)


urlChanged : Url.Url -> Session -> UserPreferences.Model -> (Session, PageModel)
urlChanged url session userPreferences =
    ({ session | url = url }, pageOf url userPreferences)


pageOf : Url.Url -> UserPreferences.Model -> PageModel
pageOf url userPreferences=
    UrlParser.parse route url
        |> Maybe.withDefault Login
        |> (\page ->
            case page of
                Login ->
                    LoginModel Login.init


                Mob name ->
                    MobModel <| Mob.Main.init name userPreferences
        )


route : Parser (Page -> c) c
route =
    oneOf
        [ map Login top
        , map Mob (s "mob" </> UrlParser.string)
        ]
