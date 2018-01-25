module Utils.Result exposing (..)


errorToMaybe : Result a b -> Maybe a
errorToMaybe result =
    case result of
        Ok _ ->
            Nothing

        Err error ->
            Just error
