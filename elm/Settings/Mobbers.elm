module Settings.Mobbers exposing (..)

import Html exposing (Html, button, div, form, i, input, li, p, text, ul)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)


type alias Mobbers =
    List String


type alias Roles =
    List String


type alias MobberRole =
    { role : String
    , name : String
    }


type alias Model =
    { newMobberName : String
    , mobbers : Mobbers
    , roles : Roles
    }


init : Model
init =
    { roles = [ "Driver", "Navigator" ]
    , newMobberName = ""
    , mobbers = []
    }


type Msg
    = AddMobber
    | NewMobberNameChanged String
    | DeleteMobber String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewMobberNameChanged newMobberName ->
            ( { model | newMobberName = newMobberName }
            , Cmd.none
            )

        AddMobber ->
            ( { model | newMobberName = "", mobbers = model.mobbers ++ [ model.newMobberName ] }
            , Cmd.none
            )

        DeleteMobber mobber ->
            ( { model | mobbers = List.filter (\m -> m /= mobber) model.mobbers }
            , Cmd.none
            )


turnEnded : Model -> Model
turnEnded model =
    { model | mobbers = rotate model.mobbers }


rotate : Mobbers -> Mobbers
rotate mobbers =
    ( List.tail mobbers, List.head mobbers )
        |> Tuple.mapSecond (Maybe.map (\it -> [ it ]))
        |> Tuple.mapBoth (Maybe.withDefault []) (Maybe.withDefault [])
        |> (\( tail, head ) -> tail ++ head)


view : Model -> Html Msg
view model =
    div [ id "mobbers", class "tab" ]
        [ form
            [ id "add", onSubmit AddMobber ]
            [ input [ type_ "text", placeholder "Mobber name", onInput NewMobberNameChanged, value model.newMobberName ] []
            , button [ type_ "submit" ] [ i [ class "fas fa-plus" ] [] ]
            ]
        , ul
            []
            (assignRoles model.mobbers model.roles
                |> List.map
                    (\mobber ->
                        li []
                            [ p [] [ text mobber.role ]
                            , div
                                []
                                [ input [ type_ "text", value <| capitalize mobber.name ] []
                                , button [ onClick <| DeleteMobber mobber.name ] [ i [ class "fas fa-times" ] [] ]
                                ]
                            ]
                    )
            )
        ]


capitalize : String -> String
capitalize string =
    (String.left 1 string |> String.toUpper)
        ++ (String.dropLeft 1 string |> String.toLower)


assignRoles : Mobbers -> Roles -> List MobberRole
assignRoles mobbers roles =
    List.indexedMap Tuple.pair mobbers
        |> List.map (\( i, name ) -> { role = getRole i roles, name = name })


getRole : Int -> Roles -> String
getRole index roles =
    List.indexedMap Tuple.pair roles
        |> List.filter (\( i, _ ) -> i == index)
        |> List.map Tuple.second
        |> List.head
        |> Maybe.withDefault "Mobber"
