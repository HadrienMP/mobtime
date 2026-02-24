module Model.Role exposing (Role, decoder, driver, encode, fromString, navigator, none, toNextUp)

import Json.Decode as Decode
import Json.Encode as Json


type alias Role =
    { name : String, description : Maybe String }


toNextUp : Role -> Role
toNextUp lastSpecialRole =
    fromString <| "Next " ++ lastSpecialRole.name


driver : Role
driver =
    { name = "Driver"
    , description = Just "The person at the keyboard. They should not take initiative. They should listen to what the navigator tells them. They should only ask clarification questions."
    }


navigator : Role
navigator =
    { name = "Navigator"
    , description = Just "The person that tells the driver what to do. They should give the intention at the highest level. They should not go into details unless requested by the driver."
    }


none : Role
none =
    fromString ""


fromString : String -> Role
fromString name =
    { name = name, description = Nothing }



-- Json


encode : Role -> Json.Value
encode role =
    Json.object
        [ ( "name", Json.string role.name )
        , ( "description", role.description |> Maybe.withDefault "" |> Json.string )
        ]


decoder : Decode.Decoder Role
decoder =
    Decode.map2 Role
        (Decode.field "name" Decode.string)
        (Decode.field "description" emptyStringToMaybe)


emptyStringToMaybe : Decode.Decoder (Maybe String)
emptyStringToMaybe =
    Decode.string
        |> Decode.map String.trim
        |> Decode.map
            (\value ->
                case value of
                    "" ->
                        Nothing

                    _ ->
                        Just value
            )
