module UI.Animations exposing (..)

import Css exposing (Style, opacity, zero)
import Css.Animations
import Lib.Duration



-- Utils


animationDuration : Lib.Duration.Duration -> Style
animationDuration duration =
    Css.animationDuration <| Css.sec <| toFloat <| Lib.Duration.toSeconds duration



-- Animation


blinkDuration : Lib.Duration.Duration
blinkDuration =
    Lib.Duration.ofSeconds 2


blink : List Style
blink =
    [ Css.animationName <|
        Css.Animations.keyframes
            [ ( 0, [ Css.Animations.opacity <| Css.num 0 ] )
            , ( 50, [ Css.Animations.opacity <| Css.num 1 ] )
            , ( 100, [ Css.Animations.opacity <| Css.num 0 ] )
            ]
    , animationDuration blinkDuration
    , Css.animationIterationCount Css.infinite
    ]


fadeDuration : Lib.Duration.Duration
fadeDuration =
    Lib.Duration.ofSeconds 1


fadeIn : List Style
fadeIn =
    [ Css.animationName <|
        Css.Animations.keyframes
            [ ( 0, [ Css.Animations.opacity <| Css.num 0 ] )
            , ( 100, [ Css.Animations.opacity <| Css.num 1 ] )
            ]
    , animationDuration fadeDuration
    ]


fadeOut : List Style
fadeOut =
    [ Css.animationName <|
        Css.Animations.keyframes
            [ ( 0, [ Css.Animations.opacity <| Css.num 1 ] )
            , ( 100, [ Css.Animations.opacity <| Css.num 0 ] )
            ]
    , animationDuration fadeDuration
    , opacity zero
    ]
