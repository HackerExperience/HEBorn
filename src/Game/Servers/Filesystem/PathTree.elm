module Game.Servers.Filesystem.PathTree
    exposing
        ( addPathNode
        , deletePathNode
        , findPathNode
        , treeToIdList
        )

import Dict
import Game.Servers.Filesystem.Shared exposing (..)


findPathNode : FilePath -> PathTree -> IOResult PathNode
findPathNode link pathTree =
    case link of
        ( [], last ) ->
            case Dict.get last pathTree of
                Just theOne ->
                    Ok theOne

                Nothing ->
                    Err MissingParent

        ( [ now ], last ) ->
            case Dict.get now pathTree of
                Just (Node _ subIndex) ->
                    findPathNode ( [], last ) subIndex

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent

        ( now :: tail, last ) ->
            case Dict.get now pathTree of
                Just (Node _ subIndex) ->
                    findPathNode ( tail, last ) subIndex

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent


addPathNode : PathNode -> FilePath -> PathTree -> IOResult PathTree
addPathNode new link pathTree =
    case link of
        ( [ now ], last ) ->
            case Dict.get now pathTree of
                Just (Node id subIndex) ->
                    subIndex
                        |> Dict.insert last new
                        |> Node id
                        |> insertIn now pathTree
                        |> Ok

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent

        ( now :: tail, last ) ->
            case Dict.get now pathTree of
                Just (Node id subIndex) ->
                    subIndex
                        |> addPathNode new ( tail, last )
                        |> Result.map (Node id >> insertIn now pathTree)

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent

        ( [], last ) ->
            pathTree
                |> Dict.insert last new
                |> Ok


deletePathNode : Bool -> FilePath -> PathTree -> IOResult PathTree
deletePathNode force link pathTree =
    case link of
        ( [], last ) ->
            case Dict.get last pathTree of
                Just (Node _ subIndex) ->
                    if (not force) && (Dict.size subIndex > 0) then
                        Err NotEmptyDir
                    else
                        Ok <| Dict.remove last pathTree

                Just (Leaf _) ->
                    Ok <| Dict.remove last pathTree

                Nothing ->
                    Err MissingParent

        ( [ now ], last ) ->
            case Dict.get now pathTree of
                Just (Node id subIndex) ->
                    subIndex
                        |> deletePathNode force ( [], last )
                        |> Result.map (Node id >> insertIn now pathTree)

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent

        ( now :: tail, last ) ->
            case Dict.get now pathTree of
                Just (Node id subIndex) ->
                    subIndex
                        |> deletePathNode force ( tail, last )
                        |> Result.map (Node id >> insertIn now pathTree)

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent


treeToIdList : PathTree -> List FileID
treeToIdList =
    Dict.values
        >> List.map
            (\x ->
                case x of
                    Leaf id ->
                        id

                    Node id _ ->
                        id
            )



-- INTERNALS


insertIn : FileName -> PathTree -> PathNode -> PathTree
insertIn id me what =
    Dict.insert id what me
