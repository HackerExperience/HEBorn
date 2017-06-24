module Utils.Dict exposing (filterMap, safeUpdate)

import Dict exposing (Dict)


filterMap :
    (comparable -> a -> Maybe b)
    -> Dict comparable a
    -> Dict comparable b
filterMap fun dict =
    let
        reducer k v acc =
            case fun k v of
                Just v_ ->
                    Dict.insert k v_ acc

                Nothing ->
                    acc
    in
        Dict.foldl reducer
            Dict.empty
            dict


safeUpdate :
    comparable
    -> a
    -> Dict.Dict comparable a
    -> Dict.Dict comparable a
safeUpdate key value dict =
    case Dict.get key dict of
        Just _ ->
            Dict.insert key value dict

        Nothing ->
            dict
