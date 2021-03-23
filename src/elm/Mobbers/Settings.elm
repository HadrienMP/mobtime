module Mobbers.Settings exposing (..)

import Html exposing (Html, button, div, form, input, li, p, text, ul)
import Html.Attributes exposing (class, disabled, id, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Lib.Icons as Icons
import Lib.ListExtras exposing (assign)
import Mobbers.Model exposing (Mobber, Mobbers)
import Random
import Random.List
import SharedEvents


type alias Model =
    { mobberName : String }


init : Model
init =
    { mobberName = "" }



-- UPDATE


type Msg
    = MobberNameChanged String
    | AddMobber
    | ShuffleMobbers
    | ShareEvent SharedEvents.Event


update : Msg -> Mobbers -> Model -> ( Model, Cmd Msg )
update msg mobbers model =
    case msg of
        MobberNameChanged name ->
            ( { model | mobberName = name }
            , Cmd.none
            )

        AddMobber ->
            ( { model | mobberName = "" }
            , Mobbers.Model.create model.mobberName
                |> SharedEvents.AddedMobber
                |> SharedEvents.toJson
                |> SharedEvents.sendEvent
            )

        ShuffleMobbers ->
            ( model, Random.generate (ShareEvent << SharedEvents.ShuffledMobbers) <| Random.List.shuffle mobbers )

        ShareEvent event ->
            -- TODO duplicated code
            ( model
            , event
                |> SharedEvents.toJson
                |> SharedEvents.sendEvent
            )



-- VIEW


view : Mobbers -> Model -> Html Msg
view mobbers model =
    div
        [ id "mobbers", class "tab" ]
        [ form
            [ id "add", onSubmit AddMobber ]
            [ input [ type_ "text", onInput MobberNameChanged, value model.mobberName ] []
            , button [ type_ "submit" ] [ Icons.plus ]
            ]
        , div [ class "button-row" ]
            [ button
                [ class "labelled-icon-button"
                , disabled (List.length mobbers < 2)
                , onClick <| ShareEvent <| SharedEvents.RotatedMobbers
                ]
                [ Icons.rotate
                , text "Rotate"
                ]
            , button
                [ class "labelled-icon-button"
                , disabled (List.length mobbers < 3)
                , onClick ShuffleMobbers
                ]
                [ Icons.shuffle
                , text "Shuffle"
                ]
            ]
        , ul []
            (mobbers
                |> assign [ "Driver", "Navigator" ]
                |> List.map mobberView
                |> List.filter ((/=) Nothing)
                |> List.map (Maybe.withDefault (li [] []))
            )
        ]


mobberView : ( Maybe String, Maybe Mobber ) -> Maybe (Html Msg)
mobberView ( role, maybeMobber ) =
    maybeMobber
        |> Maybe.map
            (\mobber ->
                li []
                    [ p [] [ text <| Maybe.withDefault "Mobber" role ]
                    , div
                        []
                        [ input [ type_ "text", value mobber.name ] []
                        , button
                            [ onClick <| ShareEvent <| SharedEvents.DeletedMobber mobber ]
                            [ Icons.delete ]
                        ]
                    ]
            )
