module Lib.Duration exposing (..)

import Json.Decode
import Json.Encode
import Time


type Duration
    = Duration Int

minus : Duration -> Duration -> Duration
minus a b =
    (toMillis a) - (toMillis b)
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
between a b =
    ( a, b )
        |> Tuple.mapBoth Time.posixToMillis Time.posixToMillis
        |> (\( a2, b2 ) -> (b2 - a2))
        |> ofMillis


div : Duration -> Duration -> Float
div numerator denominator =
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
    case duration of
        Duration s ->
            s // 60

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


toShortString : Duration -> List String
toShortString duration =
    case duration of
        Duration seconds ->
            if seconds < 60 then
                [ String.fromInt seconds ++ " s" ]

            else
                toFloat seconds
                    / 60.0
                    |> ceiling
                    |> String.fromInt
                    |> (\minutes -> [ minutes ++ " min" ])


toLongString : Duration -> List String
toLongString duration =
    case duration of
        Duration seconds ->
            let
                floatMinutes =
                    toFloat seconds / 60.0

                intMinutes =
                    floor floatMinutes

                secondsLeft =
                    seconds - (floor floatMinutes * 60)

                minutesText =
                    if intMinutes /= 0 then
                        String.fromInt intMinutes ++ " min "

                    else
                        ""

                secondsText =
                    if secondsLeft /= 0 then
                        String.fromInt secondsLeft ++ " " ++ "s"

                    else
                        ""
            in
            [ minutesText
            , secondsText
            ]
