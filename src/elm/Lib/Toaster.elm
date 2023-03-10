module Lib.Toaster exposing (Level(..), Msg(..), Toast, Toasts, error, init, jsEventMapping, success, update, view)

import Css
import Html.Styled exposing (Html, div, i, section, span, text)
import Html.Styled.Attributes exposing (class, css, id)
import Html.Styled.Events exposing (onClick)
import Js.Events
import Js.EventsMapping as EventsMapping exposing (EventsMapping)
import Lib.Delay
import Lib.Duration
import UI.Icons.Ion
import UI.Palettes as Palettes
import UI.Size as Size



-- MODEL


type Level
    = Error
    | Success


type alias Toast =
    { level : Level
    , content : String
    , autoRemove : Bool
    }


success : String -> Toast
success content =
    Toast Success content True


error : String -> Toast
error content =
    Toast Error content True


keepOn : Toast -> Toast
keepOn content =
    { content | autoRemove = False }


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
        |> List.map (\toast -> ( toast, autoRemove toast ))
        |> List.foldr (\( toast, cmd ) ( ts, cs ) -> ( toast :: ts, cmd :: cs )) ( model, [] )


autoRemove : Toast -> Cmd Msg
autoRemove toast =
    if toast.autoRemove then
        Lib.Delay.after (Lib.Duration.ofSeconds 10) (Remove toast)

    else
        Cmd.none



-- EVENTS SUBSCRIPTIONS


jsEventMapping : EventsMapping Msg
jsEventMapping =
    [ Js.Events.EventMessage "Copied" (\_ -> Add <| success "The text has been copied to your clipboard!") ]
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
        , css [ Css.zIndex <| Css.int 1000 ]
        ]
        [ icon toast.level
        , span [ class "content" ] [ text toast.content ]
        , i [ class "close las la-times close" ] []
        ]


classOf : Level -> String
classOf level =
    case level of
        Error ->
            "error"

        Success ->
            "success"


icon : Level -> Html msg
icon level =
    case level of
        Error ->
            UI.Icons.Ion.error
                { size = Size.rem 1
                , color = Palettes.monochrome.on.error
                }

        Success ->
            UI.Icons.Ion.success
                { size = Size.rem 1
                , color = Palettes.monochrome.on.success
                }
