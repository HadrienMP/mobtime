module UI.Animations exposing (bottomSlide)

import Css exposing (Style)
import Css.Animations
import Lib.Duration



-- Utils


animationDuration : Lib.Duration.Duration -> Style
animationDuration duration =
    Css.animationDuration <| Css.ms <| toFloat <| Lib.Duration.toMillis duration



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


bottomSlide : Lib.Duration.Duration -> List Style
bottomSlide duration =
    [ Css.animationName <|
        Css.Animations.keyframes
            [ ( 0, [ Css.Animations.custom "top" "100vh" ] )
            , ( 100, [ Css.Animations.custom "top" "0" ] )
            ]
    , animationDuration duration
    ]
