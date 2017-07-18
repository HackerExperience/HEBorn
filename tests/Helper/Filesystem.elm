module Helper.Filesystem exposing (..)

import Game.Servers.Filesystem.Models exposing (isEntryDirectory, addEntry)
import Game.Servers.Filesystem.Shared exposing (..)


{-| Like "mkdir -p", add folders recursively for given path.
-}
createLocation : String -> Location -> Filesystem -> Filesystem
createLocation newId location filesystem =
    case (List.reverse location) of
        [] ->
            filesystem

        [ unique ] ->
            if isEntryDirectory ( [], unique ) filesystem then
                filesystem
            else
                filesystem
                    |> addEntry
                        (FolderEntry
                            { id = newId
                            , name = unique
                            , parent = RootRef
                            }
                        )

        last :: others ->
            if isEntryDirectory ( List.reverse others, last ) filesystem then
                filesystem
            else
                filesystem
                    |> createLocation (newId ++ "_") (List.reverse others)
                    |> addEntry
                        (FolderEntry
                            { id = newId
                            , name = last
                            , parent = RootRef
                            }
                        )


hackPath : ParentReference -> Entry -> Entry
hackPath newParent entry =
    case entry of
        FileEntry file ->
            FileEntry { file | parent = newParent }

        FolderEntry folder ->
            FolderEntry { folder | parent = newParent }
