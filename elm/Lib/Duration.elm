module Lib.Duration exposing (..)


type Duration
    = Duration Int


div : Duration -> Duration -> Float
div numerator denominator =
    let
        numeratorSeconds = toSeconds numerator |> toFloat
        denominatorSeconds = toSeconds denominator |> toFloat
    in
    numeratorSeconds / denominatorSeconds

toSeconds : Duration -> Int
toSeconds duration =
    case duration of
        Duration s -> s

toMinutes : Duration -> Int
toMinutes duration =
    case duration of
        Duration s -> s // 60

ofSeconds : Int -> Duration
ofSeconds seconds =
    Duration seconds


ofMinutes : Int -> Duration
ofMinutes minutes =
    Duration <| minutes * 60


subtract : Duration -> Duration -> Duration
subtract a b =
    toSeconds a - toSeconds b
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
