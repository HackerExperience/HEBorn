module Game.Servers.Filesystem.ModelTest exposing (all)

import Expect
import Gen.Filesystem as Gen
import Fuzz exposing (int, tuple, tuple3, tuple4)
import Helper.Filesystem as Helper exposing (createLocation, hackPath)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Game.Servers.Filesystem.Shared exposing (..)
import Game.Servers.Filesystem.Models exposing (..)


all : Test
all =
    describe "filesystem"
        [ fileOperationsTests
        ]


fileOperationsTests : Test
fileOperationsTests =
    describe "file operations"
        [ describe "add file"
            addFileTests
        , describe "move file"
            moveFileTests
        , describe "delete files"
            deleteFileTests
        ]



--------------------------------------------------------------------------------
-- Add File
--------------------------------------------------------------------------------


addFileTests : List Test
addFileTests =
    [ describe "generic add file tests "
        addFileGenericTests
    ]


addFileGenericTests : List Test
addFileGenericTests =
    [ fuzz
        (tuple ( Gen.model, Gen.file ))
        "can't add stdfile to non-existing path (no recursive)"
      <|
        \( model, file ) ->
            model
                |> addEntry
                    (hackPath (NodeRef "inexistant") file)
                |> Expect.equal model
    , fuzz
        (tuple ( Gen.model, Gen.file ))
        "can add stdfile to non-existing path (recursively)"
      <|
        \( filesystem, file ) ->
            let
                fileID =
                    getEntryId file

                model =
                    addEntry file filesystem
            in
                file
                    |> flip getEntryLocation model
                    |> flip findChildren model
                    |> List.filter (\x -> (getEntryId x) == fileID)
                    |> List.head
                    |> Expect.equal (Just file)

    {- test below probably will need revision: we *can* add folder to non-existing path
       as long as the top-level path exists. Example:
       we can add Folder f to /path/f when /path exists (and /path/f obviously doesn't)
       we can't add Folder f to /path/to/f when /path exists but /path/to does not.
    -}
    , fuzz
        (tuple ( Gen.model, Gen.folder ))
        "can add folders to non-existing path"
      <|
        \( model, folder ) ->
            let
                originalModel =
                    model
                        |> addEntry folder

                loc =
                    getEntryLocation folder originalModel
            in
                originalModel
                    |> isLocationValid loc
                    |> Expect.equal True
    , fuzz
        (tuple4 ( Gen.model, Gen.folder, Gen.file, Gen.file ))
        "multiple files can exist on the same folder"
      <|
        \( model, folder, file1, file2 ) ->
            let
                parentRef =
                    NodeRef <| getEntryId folder

                file1_ =
                    hackPath parentRef file1

                file2_ =
                    hackPath parentRef file2

                fullModel =
                    model
                        |> addEntry folder
                        |> addEntry file1_
                        |> addEntry file2_

                ( loc, name ) =
                    getEntryLink folder fullModel

                childs =
                    findChildren (loc ++ [ name ]) fullModel

                result =
                    ( List.member file1_ childs
                    , List.member file2_ childs
                    )
            in
                Expect.equal ( True, True ) result
    ]



--------------------------------------------------------------------------------
-- Move File
--------------------------------------------------------------------------------


moveFileTests : List Test
moveFileTests =
    [ describe "generic tests"
        moveFileGenericTests
    , describe "move stdfile around"
        moveStdFileTests
    , describe "move folders around"
        moveFolderTests
    ]


moveFileGenericTests : List Test
moveFileGenericTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.entry, Gen.location ))
        "can't move file to non-existing path"
      <|
        \( filesystem, file, destination ) ->
            let
                model =
                    addEntry file filesystem
            in
                model
                    |> moveEntry
                        ( destination, getEntryBasename file )
                        file
                    |> Expect.equal model
    ]


moveStdFileTests : List Test
moveStdFileTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.file, Gen.folder ))
        "file is present on new location"
      <|
        \( model, file, folder ) ->
            let
                fileID =
                    getEntryId file

                originalModel =
                    model
                        |> addEntry file
                        |> addEntry folder

                ( grandLoc, fatherName ) =
                    getEntryLink folder originalModel

                destAsLoc =
                    grandLoc ++ [ fatherName ]

                destination =
                    ( destAsLoc, getEntryBasename file )

                fullModel =
                    originalModel
                        |> moveEntry destination file
            in
                fullModel
                    |> findChildren destAsLoc
                    |> List.filter (\x -> (getEntryId x) == fileID)
                    |> List.head
                    |> Maybe.map getEntryId
                    |> Expect.equal (Just fileID)
    , fuzz
        (tuple3 ( Gen.model, Gen.file, Gen.folder ))
        "file is absent on old location"
      <|
        \( model, file, folder ) ->
            let
                fileID =
                    getEntryId file

                originalModel =
                    model
                        |> addEntry file
                        |> addEntry folder

                originalLocation =
                    getEntryLocation file originalModel

                folderAsLoc =
                    getEntryLocation folder originalModel
                        ++ [ getEntryBasename folder ]

                destination =
                    ( folderAsLoc
                    , getEntryBasename file
                    )
            in
                originalModel
                    |> moveEntry destination file
                    |> findChildren originalLocation
                    |> List.filter (\x -> (getEntryId x) == fileID)
                    |> List.head
                    |> Expect.equal Nothing
    , fuzz
        (tuple3 ( Gen.model, Gen.file, Gen.folder ))
        "old path is still present"
      <|
        \( model, file, folder ) ->
            let
                originalModel =
                    model
                        |> addEntry file
                        |> addEntry folder

                newLoc =
                    getEntryLocation folder originalModel
                        ++ [ getEntryBasename folder ]

                oldParent =
                    getEntryLocation file originalModel
            in
                originalModel
                    |> moveEntry
                        ( newLoc, getEntryBasename file )
                        file
                    |> isLocationValid oldParent
                    |> Expect.equal True
    ]


moveFolderTests : List Test
moveFolderTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.entry, Gen.folder ))
        "folder is present on new location"
      <|
        \( model, file, folder ) ->
            let
                fileID =
                    getEntryId file

                originalModel =
                    model
                        |> addEntry file
                        |> addEntry folder

                (( newLoc, newName ) as destination) =
                    ( getEntryLocation folder originalModel, getEntryBasename file )
            in
                originalModel
                    |> moveEntry destination file
                    |> findChildren newLoc
                    |> List.filter (\x -> (getEntryId x) == fileID)
                    |> List.head
                    |> Maybe.map getEntryId
                    |> Expect.equal (Just fileID)

    {- We moved /bar to /foo, so now we have /foo/bar. We need to ensure our
       model recognizes path /foo/bar as valid
    -}
    , fuzz
        (tuple3 ( Gen.model, Gen.folder, Gen.folder ))
        "new folder path is added to the model"
      <|
        \( model, origin, target ) ->
            let
                originalModel =
                    model
                        |> addEntry origin
                        |> addEntry target

                destination =
                    getEntryLocation target originalModel

                newLink =
                    ( destination, getEntryBasename origin )
            in
                originalModel
                    |> moveEntry newLink origin
                    |> isEntryDirectory newLink
                    |> Expect.equal True
    , fuzz
        (tuple4 ( Gen.model, Gen.entry, Gen.folder, Gen.folder ))
        "we can move a new file into the moved folder"
      <|
        \( model, file, folder1, folder2 ) ->
            let
                originalModel =
                    model
                        |> addEntry folder1
                        |> addEntry folder2

                ( newGrandpa, newParent ) =
                    getEntryLink folder2 originalModel

                newLink =
                    ( newGrandpa ++ [ newParent ], getEntryBasename folder1 )

                newFileLocation =
                    Tuple.first newLink ++ [ Tuple.second newLink ]

                fileID =
                    getEntryId file

                parentRef =
                    NodeRef <| getEntryId folder1

                file_ =
                    hackPath parentRef file
            in
                originalModel
                    |> moveEntry newLink folder1
                    |> addEntry file_
                    |> findChildren newFileLocation
                    |> List.filter (\x -> (getEntryId x) == fileID)
                    |> List.head
                    |> Expect.equal (Just file_)
    , fuzz
        (tuple3 ( Gen.model, Gen.folder, Gen.folder ))
        "old folder path no longer exists"
      <|
        \( model, folder1, folder2 ) ->
            let
                originalModel =
                    model
                        |> addEntry folder1
                        |> addEntry folder2

                ( f2parent, f2name ) =
                    getEntryLink folder2 originalModel

                originalLink =
                    getEntryLink folder1 originalModel

                destination =
                    ( f2parent ++ [ f2name ], getEntryBasename folder1 )
            in
                originalModel
                    |> moveEntry destination folder1
                    |> isEntryDirectory originalLink
                    |> Expect.equal False
    ]



--------------------------------------------------------------------------------
-- Delete File
--------------------------------------------------------------------------------


deleteFileTests : List Test
deleteFileTests =
    [ describe "delete stdfile"
        deleteStdFileTests
    , describe "delete folder"
        deleteFolderTests
    ]


deleteStdFileTests : List Test
deleteStdFileTests =
    [ fuzz
        (tuple ( Gen.model, Gen.file ))
        "stdfile no longer exists on path"
      <|
        \( model, file ) ->
            let
                fileID =
                    getEntryId file

                originalModel =
                    addEntry file model

                originalLocation =
                    getEntryLocation file originalModel
            in
                originalModel
                    |> deleteEntry file
                    |> findChildren originalLocation
                    |> List.filter (\x -> (getEntryId x) == fileID)
                    |> List.head
                    |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.model, Gen.file ))
        "removed stdfile path still exists"
      <|
        \( model, file ) ->
            let
                originalModel =
                    addEntry file model

                loc =
                    getEntryLocation file originalModel
            in
                originalModel
                    |> deleteEntry file
                    |> isLocationValid loc
                    |> Expect.equal True
    , fuzz
        (tuple3 ( Gen.model, Gen.file, Gen.file ))
        "'sister' files still exists on that path"
      <|
        \( model, file, file2 ) ->
            let
                parentRef =
                    getEntryParent file

                sister =
                    hackPath parentRef file2

                sisterID =
                    getEntryId sister

                originalModel =
                    model
                        |> addEntry file
                        |> addEntry sister

                path =
                    getEntryLocation file originalModel
            in
                originalModel
                    |> deleteEntry file
                    |> findChildren path
                    |> List.filter (\x -> (getEntryId x) == sisterID)
                    |> List.head
                    |> Expect.equal (Just sister)
    ]


deleteFolderTests : List Test
deleteFolderTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.entry, Gen.folder ))
        "won't delete folder when there are files inside"
      <|
        \( filesystem, file, folder ) ->
            let
                parentRef =
                    NodeRef <| getEntryId folder

                file_ =
                    hackPath parentRef file

                model =
                    filesystem
                        |> addEntry folder
                        |> addEntry file_
            in
                model
                    |> deleteEntry folder
                    |> Expect.equal model
    , fuzz
        (tuple ( Gen.model, Gen.folder ))
        "folder no longer exists on path"
      <|
        \( model, folder ) ->
            let
                originalModel =
                    model
                        |> addEntry folder

                originalLocation =
                    getEntryLocation folder originalModel

                folderID =
                    getEntryId folder
            in
                originalModel
                    |> deleteEntry folder
                    |> findChildren originalLocation
                    |> List.filter (\x -> (getEntryId x) == folderID)
                    |> List.head
                    |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.model, Gen.folder ))
        "folder path no longer exists"
      <|
        \( model, folder ) ->
            let
                fullModel =
                    model
                        |> addEntry folder
                        |> deleteEntry folder
            in
                fullModel
                    |> isEntryDirectory (getEntryLink folder fullModel)
                    |> Expect.equal False
    ]
