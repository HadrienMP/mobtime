module Lib.StringExtra exposing (capitalize)


capitalize : String -> String
capitalize string =
    case String.toList string of
        head :: tail ->
            Char.toUpper head :: tail |> String.fromList

        [] ->
            string
