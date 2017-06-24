module Utils.String exposing (fromBool, fromMaybe)


fromBool : Bool -> String
fromBool bool =
    case bool of
        True ->
            "true"

        False ->
            "false"


fromMaybe : Maybe String -> String
fromMaybe maybe =
    case maybe of
        Just something ->
            something

        Nothing ->
            ""
