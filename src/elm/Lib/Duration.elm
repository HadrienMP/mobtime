module Lib.Duration exposing (..)

import Json.Decode
import Json.Encode
import Lib.ListExtras exposing (uncons)
import Time


type Duration
    = Duration Int


type alias DurationStringParts =
    List String


addToTime : Duration -> Time.Posix -> Time.Posix
addToTime duration time =
    Time.posixToMillis time
        |> (+) (toMillis duration)
        |> Time.millisToPosix


minus : Duration -> Duration -> Duration
minus a b =
    toMillis a
        - toMillis b
        |> ofMillis


multiply : Int -> Duration -> Duration
multiply multiplier duration =
    toMillis duration
        |> (*) multiplier
        |> ofMillis


toJson : Duration -> Json.Encode.Value
toJson duration =
    Json.Encode.int <| toMillis duration


jsonDecoder : Json.Decode.Decoder Duration
jsonDecoder =
    Json.Decode.int
        |> Json.Decode.map ofMillis


secondsBetween : Time.Posix -> Time.Posix -> Int
secondsBetween a b =
    toSeconds <| between a b


between : Time.Posix -> Time.Posix -> Duration
between before after =
    ( before, after )
        |> Tuple.mapBoth Time.posixToMillis Time.posixToMillis
        |> (\( a2, b2 ) -> b2 - a2)
        |> ofMillis


div : Duration -> Int -> Duration
div numerator denominator =
    ofMillis <| toMillis numerator // denominator


ratio : Duration -> Duration -> Float
ratio numerator denominator =
    let
        numeratorSeconds =
            toSeconds numerator |> toFloat

        denominatorSeconds =
            toSeconds denominator |> toFloat
    in
    numeratorSeconds / denominatorSeconds


toSeconds : Duration -> Int
toSeconds duration =
    case duration of
        Duration s ->
            s // 1000


toMillis : Duration -> Int
toMillis duration =
    case duration of
        Duration s ->
            s


toMinutes : Duration -> Int
toMinutes duration =
    toSeconds duration // 60


ofMillis : Int -> Duration
ofMillis int =
    Duration int


ofSeconds : Int -> Duration
ofSeconds seconds =
    ofMillis <| seconds * 1000


ofMinutes : Int -> Duration
ofMinutes minutes =
    ofSeconds <| minutes * 60


subtract : Duration -> Duration -> Duration
subtract a b =
    toSeconds a
        - toSeconds b
        |> ofSeconds


print : Duration -> String
print duration =
    toShortString duration |> String.join " "


toShortString : Duration -> List String
toShortString duration =
    let
        seconds =
            toSeconds duration |> abs
    in
    if seconds < 60 then
        [ overtimeSign duration ++ String.fromInt seconds ++ " s" ]

    else
        toFloat seconds
            / 60.0
            |> ceiling
            |> String.fromInt
            |> (\minutes -> [ overtimeSign duration ++ minutes ++ " min" ])


overtimeSign : Duration -> String
overtimeSign duration =
    if toMillis duration < 0 then
        "+"

    else
        ""


toLongString : Duration -> DurationStringParts
toLongString duration =
    let
        seconds =
            toSeconds duration
                |> abs

        floatMinutes =
            toFloat seconds / 60.0

        intMinutes =
            floor floatMinutes

        secondsLeft =
            seconds - (floor floatMinutes * 60)

        minutesText =
            if intMinutes /= 0 then
                [ String.fromInt intMinutes ++ " min " ]

            else
                []

        secondsText =
            if secondsLeft /= 0 then
                [ String.fromInt secondsLeft ++ " " ++ "s" ]

            else
                []

        a =
            minutesText
                ++ secondsText
                |> List.filter (not << String.isEmpty)

        ( first, second ) =
            uncons a |> Tuple.mapFirst (Maybe.withDefault "" >> (++) (overtimeSign duration))
    in
    first :: second
