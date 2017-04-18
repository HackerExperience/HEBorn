module Utils
    exposing
        ( msgToCmd
        , boolToString
        , maybeToString
        , delay
        , safeUpdateDict
        )

import Dict
import Time
import Task
import Process


-- I know this is not how it's supposed to be done but until I get a better
-- grasp of Elm, it's good enough.


msgToCmd : a -> Cmd a
msgToCmd msg =
    Task.perform (always msg) (Task.succeed ())


boolToString : Bool -> String
boolToString bool =
    case bool of
        True ->
            "true"

        False ->
            "false"


maybeToString : Maybe String -> String
maybeToString maybe =
    case maybe of
        Just something ->
            something

        Nothing ->
            ""


delay : Float -> msg -> Cmd msg
delay seconds msg =
    Process.sleep (Time.second * seconds)
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


safeUpdateDict :
    Dict.Dict comparable a
    -> comparable
    -> a
    -> Dict.Dict comparable a
safeUpdateDict dict key value =
    let
        fnUpdate item =
            case item of
                Just _ ->
                    Just value

                Nothing ->
                    Nothing
    in
        Dict.update key fnUpdate dict
