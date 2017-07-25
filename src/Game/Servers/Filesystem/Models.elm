module Game.Servers.Filesystem.Models exposing (..)

import Dict
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.PathTree exposing (..)


initialFilesystem : Filesystem
initialFilesystem =
    { entries = Dict.empty, rootTree = Dict.empty }


getEntryId : Entry -> FileID
getEntryId entry =
    case entry of
        FileEntry file ->
            file.id

        FolderEntry folder ->
            folder.id


getEntryLocation : Entry -> Filesystem -> Location
getEntryLocation entry filesystem =
    entry
        |> getEntryParent
        |> getAncestorsList filesystem
        |> List.reverse
        |> List.map (getEntryName)


getEntryBasename : Entry -> String
getEntryBasename entry =
    case entry of
        FileEntry file ->
            file.name

        FolderEntry folder ->
            folder.name


getEntryName : Entry -> String
getEntryName entry =
    case entry of
        FileEntry prop ->
            -- TODO: add extension with a new function like getFileExtension
            (getEntryBasename entry) ++ extensionSeparator ++ prop.extension

        FolderEntry _ ->
            getEntryBasename entry


getEntryLink : Entry -> Filesystem -> FilePath
getEntryLink entry filesystem =
    let
        name =
            getEntryName entry

        loc =
            getEntryLocation entry filesystem
    in
        ( loc, name )


getEntryParent : Entry -> ParentReference
getEntryParent entry =
    case entry of
        FileEntry file ->
            file.parent

        FolderEntry folder ->
            folder.parent


getEntry : FileID -> Filesystem -> Maybe Entry
getEntry entryID filesystem =
    Dict.get entryID filesystem.entries


findEntryId : FilePath -> Filesystem -> Maybe FileID
findEntryId link filesystem =
    case findPathNode link filesystem.rootTree of
        Ok (Leaf id) ->
            Just id

        Ok (Node id _) ->
            Just id

        _ ->
            Nothing


findEntry : FilePath -> Filesystem -> Maybe Entry
findEntry link filesystem =
    filesystem
        |> findEntryId link
        |> Maybe.andThen ((flip getEntry) filesystem)


isParentValid : Entry -> Filesystem -> Bool
isParentValid entry filesystem =
    case getEntryParent entry of
        RootRef ->
            True

        NodeRef id ->
            Dict.member id filesystem.entries


addEntry : Entry -> Filesystem -> Filesystem
addEntry entry filesystem =
    if (isParentValid entry filesystem) then
        let
            location =
                getEntryLocation entry

            id =
                getEntryId entry

            link =
                getEntryLink entry filesystem

            newElem =
                case entry of
                    FileEntry _ ->
                        Leaf id

                    FolderEntry _ ->
                        Node id Dict.empty

            rootTree =
                addPathNode
                    newElem
                    link
                    filesystem.rootTree
        in
            case rootTree of
                Ok rootTree ->
                    let
                        entries =
                            Dict.insert
                                id
                                entry
                                filesystem.entries
                    in
                        { entries = entries, rootTree = rootTree }

                Err _ ->
                    -- It's possible to return THE ERROR
                    filesystem
    else
        filesystem


deleteEntry : Entry -> Filesystem -> Filesystem
deleteEntry entry filesystem =
    let
        link =
            getEntryLink entry filesystem

        id =
            getEntryId entry

        rootTree =
            deletePathNode False link filesystem.rootTree
    in
        case rootTree of
            Ok rootTree ->
                let
                    entries =
                        Dict.remove id filesystem.entries
                in
                    { entries = entries, rootTree = rootTree }

            _ ->
                filesystem


moveEntry : FilePath -> Entry -> Filesystem -> Filesystem
moveEntry (( newLoc, newName ) as newLink) entry filesystem =
    let
        originalLink =
            getEntryLink entry filesystem

        pathNode =
            findPathNode originalLink filesystem.rootTree

        newParent =
            locationToParentRef newLoc filesystem

        fullLink =
            case entry of
                FileEntry prop ->
                    ( newLoc
                    , newName ++ extensionSeparator ++ prop.extension
                    )

                FolderEntry _ ->
                    newLink
    in
        case ( pathNode, newParent ) of
            ( Ok pathNode, Just newParent ) ->
                let
                    rootTreeRes =
                        filesystem.rootTree
                            |> deletePathNode True originalLink
                            |> Result.andThen (addPathNode pathNode fullLink)
                in
                    case rootTreeRes of
                        Ok rootTree_ ->
                            let
                                apply header =
                                    { header | name = newName, parent = newParent }

                                entry_ =
                                    case entry of
                                        FileEntry fileBox ->
                                            fileBox |> apply |> FileEntry

                                        FolderEntry folderBox ->
                                            folderBox |> apply |> FolderEntry

                                entries =
                                    Dict.insert (getEntryId entry) entry_ filesystem.entries
                            in
                                { entries = entries, rootTree = rootTree_ }

                        _ ->
                            filesystem

            _ ->
                filesystem


nodeExists : FilePath -> Filesystem -> Bool
nodeExists link filesystem =
    case findPathNode link filesystem.rootTree of
        Ok _ ->
            True

        _ ->
            False


isEntryDirectory : FilePath -> Filesystem -> Bool
isEntryDirectory link filesystem =
    case findPathNode link filesystem.rootTree of
        Ok (Node id _) ->
            True

        _ ->
            False


isLocationValid : Location -> Filesystem -> Bool
isLocationValid loc filesystem =
    case (List.reverse loc) of
        [] ->
            True

        [ unique ] ->
            isEntryDirectory ( [], unique ) filesystem

        last :: others ->
            isEntryDirectory ( List.reverse others, last ) filesystem


findChildrenIds : Location -> PathTree -> IOResult (List FileID)
findChildrenIds loc pathTree =
    case loc of
        [] ->
            Ok <| treeToIdList pathTree

        [ now ] ->
            case (Dict.get now pathTree) of
                Just (Node _ childTree) ->
                    Ok <| treeToIdList childTree

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent

        now :: tail ->
            case (Dict.get now pathTree) of
                Just (Node _ childTree) ->
                    findChildrenIds tail childTree

                Just (Leaf _) ->
                    Err ParentIsFile

                Nothing ->
                    Err MissingParent


findChildren : Location -> Filesystem -> List Entry
findChildren loc filesystem =
    filesystem.rootTree
        |> findChildrenIds loc
        |> Result.map
            (List.filterMap
                ((flip getEntry) filesystem)
            )
        |> Result.withDefault []


isValidFilename : String -> Bool
isValidFilename fName =
    -- TODO: Add special characters & entire name validation
    if String.length fName > 0 then
        False
    else if String.length fName < 255 then
        False
    else
        True


getFileModules : Entry -> Modules
getFileModules entry =
    case entry of
        FileEntry file ->
            file.modules

        FolderEntry folder ->
            []


locationToParentRef : Location -> Filesystem -> Maybe ParentReference
locationToParentRef loc filesystem =
    case (List.reverse loc) of
        [] ->
            Just RootRef

        [ unique ] ->
            filesystem
                |> findEntryId ( [], unique )
                |> Maybe.map NodeRef

        last :: others ->
            ( List.reverse others, last )
                |> (flip findEntryId) filesystem
                |> Maybe.map NodeRef


getAncestorsList : Filesystem -> ParentReference -> List Entry
getAncestorsList filesystem parent =
    case parent of
        RootRef ->
            []

        NodeRef id ->
            let
                entry =
                    getEntry id filesystem
            in
                case entry of
                    Just entry ->
                        getEntryParent entry
                            |> getAncestorsList filesystem
                            |> ((::) entry)

                    _ ->
                        -- ATTENTION: Correct action = IOErr MissingParent
                        []
