module Lib.Toaster exposing (..)

import Html exposing (Html, div, i, section, span, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.Delay
import Lib.Icons
import Js.Events



-- MODEL


type Level
    = Info
    | Error
    | Warning
    | Success


type alias Toast =
    { level : Level
    , content : String
    }


type alias Toasts =
    List Toast


init : Toasts
init =
    []



-- UPDATE


type Msg
    = Add Toast
    | Remove Toast


update : Msg -> Toasts -> ( Toasts, Cmd Msg )
update msg toasts =
    case msg of
        Add toast ->
            add [ toast ] toasts
                |> Tuple.mapSecond Cmd.batch

        Remove toast ->
            ( List.filter (\t -> t /= toast) toasts
            , Cmd.none
            )


add : Toasts -> Toasts -> ( Toasts, List (Cmd Msg) )
add toAdd model =
    toAdd
        |> List.filter (\toast -> not (List.member toast model))
        |> List.map (\toast -> ( toast, Lib.Delay.after (Lib.Delay.Seconds 10) (Remove toast) ))
        |> List.foldr (\( toast, cmd ) ( ts, cs ) -> ( toast :: ts, cmd :: cs )) ( model, [] )



-- EVENTS SUBSCRIPTIONS


eventsMapping : EventsMapping Msg
eventsMapping =
    [ Js.Events.EventMessage "Copied" (\_ -> Add <| Toast Success "The text has been copied to your clipboard!") ]
        |> EventsMapping.create



-- VIEW


view : Toasts -> Html Msg
view toasts =
    section
        [ id "toasts" ]
        (List.map viewToast toasts)


viewToast : Toast -> Html Msg
viewToast toast =
    div
        [ class <| "toast " ++ classOf toast.level
        , onClick <| Remove toast
        ]
        [ icon toast.level
        , span [ class "content" ] [ text toast.content ]
        , i [ class "close las la-times close" ] []
        ]


classOf : Level -> String
classOf level =
    case level of
        Info ->
            "info"

        Error ->
            "error"

        Warning ->
            "warning"

        Success ->
            "success"


icon : Level -> Html msg
icon level =
    case level of
        Info ->
            Lib.Icons.info

        Error ->
            Lib.Icons.error

        Warning ->
            Lib.Icons.warning

        Success ->
            Lib.Icons.success
