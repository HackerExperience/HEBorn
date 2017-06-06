module Utils exposing (..)

import Time
import Task
import Process
import Dict exposing (Dict)
import Html exposing (Attribute)
import Html.Events exposing (on, keyCode)
import Json.Decode as Json


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


filterMapDict :
    (comparable -> a -> Maybe b)
    -> Dict comparable a
    -> Dict comparable b
filterMapDict fun dict =
    Dict.foldl
        (\k v acc ->
            case fun k v of
                Just v_ ->
                    Dict.insert k v_ acc

                Nothing ->
                    acc
        )
        Dict.empty
        dict


filterMapList :
    (a -> Maybe b)
    -> List a
    -> List b
filterMapList fun list =
    List.foldl
        (\a acc ->
            case fun a of
                Just a_ ->
                    a_ :: acc

                Nothing ->
                    acc
        )
        []
        list


{-| Swaps the first argument of a 3-arity function with the last. Can be
helpful with test chains like:

    processes
        |> getProcessByID process.id
        |> andJust ((swap resumeProcess) processes 1)

To work with 2-arity functions, use the flip function from core.

-}
swap : (a -> b -> c -> d) -> c -> b -> a -> d
swap function =
    (\a b c -> function c b a)


{-| Like Maybe.andThen, but always returns `Just something`.
-}
andJust : (a -> b) -> Maybe a -> Maybe b
andJust callback maybe =
    case maybe of
        Just value ->
            Just (callback value)

        Nothing ->
            Nothing


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)


andThenWithDefault : (a -> b) -> b -> Maybe a -> b
andThenWithDefault callback default maybe =
    case maybe of
        Just value ->
            callback value

        Nothing ->
            default
