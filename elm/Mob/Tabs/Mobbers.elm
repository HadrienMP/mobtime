module Mob.Tabs.Mobbers exposing (..)

import Mob.Clock.Events
import Html exposing (Html, button, div, form, i, input, li, p, text, ul)
import Html.Attributes exposing (class, id, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Random
import Random.List


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



-- UPDATE


type Msg
    = AddMobber
    | NewMobberNameChanged String
    | DeleteMobber String
    | Rotate
    | Shuffle
    | Shuffled Mobbers


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

        Rotate ->
            ( { model | mobbers = rotate model.mobbers }
            , Cmd.none
            )

        Shuffle ->
            ( model, Random.generate Shuffled <| Random.List.shuffle model.mobbers )

        Shuffled mobbers ->
            ( { model | mobbers = mobbers }, Cmd.none )



-- CLOCK DEPENDENCY


type alias EventHandlingResult =
    { model : Model
    , command : Cmd Msg
    }


handleClockEvents : Model -> Maybe Mob.Clock.Events.Event -> EventHandlingResult
handleClockEvents model maybeEvent =
    case maybeEvent of
        Just event ->
            case event of
                Mob.Clock.Events.Finished ->
                    EventHandlingResult { model | mobbers = rotate model.mobbers } Cmd.none

                Mob.Clock.Events.Started ->
                    EventHandlingResult model Cmd.none

        Nothing ->
            EventHandlingResult model Cmd.none


rotate : Mobbers -> Mobbers
rotate mobbers =
    ( List.tail mobbers, List.head mobbers )
        |> Tuple.mapSecond (Maybe.map (\it -> [ it ]))
        |> Tuple.mapBoth (Maybe.withDefault []) (Maybe.withDefault [])
        |> (\( tail, head ) -> tail ++ head)



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "mobbers", class "tab" ]
        [ form
            [ id "add", onSubmit AddMobber ]
            [ input [ type_ "text", placeholder "Mobber name", onInput NewMobberNameChanged, value model.newMobberName ] []
            , button [ type_ "submit" ] [ i [ class "fas fa-plus" ] [] ]
            ]
        , div [] (rotateButton model ++ shuffleButton model)
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


rotateButton : Model -> List (Html Msg)
rotateButton model =
    if List.length model.mobbers > 1 then
        [ button [ onClick Rotate ] [ text "Rotate" ] ]

    else
        []


shuffleButton : Model -> List (Html Msg)
shuffleButton model =
    if List.length model.mobbers > 2 then
        [ button [ onClick Shuffle ] [ text "Shuffle" ] ]

    else
        []


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
