module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.
To add packages that contain rules, add them to this review project using
    `elm install author/packagename`
when inside the directory containing this file.
-}

import CognitiveComplexity
import NoDebug.Log
import NoDebug.TodoOrToString
import NoDeprecated
import NoExposingEverything
import NoImportingEverything
import NoInconsistentAliases
import NoMissingSubscriptionsCall
import NoMissingTypeAnnotation
import NoMissingTypeExpose
import NoModuleOnExposedNames
import NoPrematureLetComputation
import NoRecursiveUpdate
import NoSimpleLetBody
import NoUnnecessaryTrailingUnderscore
import NoUnoptimizedRecursion
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import NoUrlStringConcatenation
import NoUselessSubscriptions
import Review.Rule exposing (Rule)
import Simplify


config : List Rule
config =
    (commonBestPractices
        ++ noUnused
        ++ elmArchitecture
        ++ noDebug
        ++ [ Simplify.rule Simplify.defaults
           , NoUnoptimizedRecursion.rule (NoUnoptimizedRecursion.optOutWithComment "IGNORE TCO")
           , NoUrlStringConcatenation.rule
           , NoUnnecessaryTrailingUnderscore.rule
           , NoSimpleLetBody.rule
           , CognitiveComplexity.rule 10
           , NoInconsistentAliases.config
                [ ( "Widget.Material", "Material" )
                , ( "Widget.Material.Color", "MaterialColor" )
                , ( "Material.Icons.Outlined", "MaterialIcons" )
                , ( "Json.Decode", "Decode" )
                , ( "Json.Encode", "Json" )
                , ( "Element.Font", "Font" )
                , ( "Element.Border", "Border" )
                , ( "Element.Background", "Background" )
                , ( "Element.Input", "Input" )
                , ( "UI.Rem", "Rem")
                , ( "UI.Space", "Space")
                , ( "UI.Row", "Row")
                , ( "UI.Column", "Column")
                , ( "UI.Text", "Text")
                , ( "UI.Color", "Color")
                , ( "UI.Palettes", "Palettes")
                , ( "UI.Typography.Typography", "Typography")
                ]
                |> NoInconsistentAliases.noMissingAliases
                |> NoInconsistentAliases.rule
           ]
    )


commonBestPractices : List Rule
commonBestPractices =
    [ NoExposingEverything.rule
        |> Review.Rule.ignoreErrorsForDirectories [ "tests" ]
    , NoDeprecated.rule NoDeprecated.defaults
    , NoImportingEverything.rule []
        |> Review.Rule.ignoreErrorsForDirectories [ "tests" ]
    , NoMissingTypeAnnotation.rule
    , NoMissingTypeExpose.rule
    , NoPrematureLetComputation.rule
    ]


noUnused : List Rule
noUnused =
    [ NoUnused.CustomTypeConstructors.rule []
    , NoUnused.CustomTypeConstructorArgs.rule
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule
    , NoUnused.Modules.rule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    ]


elmArchitecture : List Rule
elmArchitecture =
    [ NoMissingSubscriptionsCall.rule
    , NoRecursiveUpdate.rule
    , NoUselessSubscriptions.rule
    ]


noDebug : List Rule
noDebug =
    [ NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule
    ]
