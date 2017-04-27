module Game.Servers.Filesystem.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
import Utils exposing (andJust)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Filesystem as Gen
import Helper.Filesystem as Helper exposing (addFileRecursively)
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
    [ fuzz (tuple ( int, int ))
        "can't add stdfile to non-existing path (no recursive)"
      <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                model =
                    Gen.fsRandom seed1

                model_ =
                    addFile (Gen.stdFile seed2) model
            in
                Expect.equal model model_
    , fuzz (tuple ( int, int ))
        "can add stdfile to non-existing path (recursively)"
      <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.stdFile seed1

                stdFileID =
                    getFileId stdFile

                model =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile

                filesOnPath =
                    getFilesOnPath (getFilePath stdFile) model

                maybeFile =
                    filesOnPath
                        |> List.filter (\x -> (getFileId x) == stdFileID)
                        |> List.head
            in
                Expect.equal maybeFile (Just stdFile)

    {- test below probably will need revision: we *can* add folder to non-existing path
       as long as the top-level path exists. Example:
       we can add Folder f to /path/f when /path exists (and /path/f obviously doesn't)
       we can't add Folder f to /path/to/f when /path exists but /path/to does not.
    -}
    , fuzz (tuple ( int, int )) "can add folders to non-existing path" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                folder =
                    Gen.folder seed1

                model =
                    seed2
                        |> Gen.fsRandom
                        |> addFileRecursively folder
            in
                Expect.equal (pathExists (getFilePath folder) model) True
    , fuzz (tuple ( int, int )) "multiple files can exist on the same folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                folder =
                    Gen.folder (seed1 + 1)

                path =
                    getFilePath folder

                file1 =
                    seed2
                        |> Gen.stdFile
                        |> setFilePath path

                file2 =
                    seed2
                        |> (+) 1
                        |> Gen.stdFile
                        |> setFilePath path

                filesOnPath =
                    seed1
                        |> Gen.fsRandom
                        |> addFile folder
                        |> addFile file1
                        |> addFile file2
                        |> getFilesOnPath path
            in
                Expect.equal
                    ([ folder ] ++ [ file1 ] ++ [ file2 ])
                    filesOnPath
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
    [ fuzz (tuple ( int, int )) "cant move file to non-existing path" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.file seed1

                destination =
                    Gen.path seed2

                model =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile

                model_ =
                    moveFile destination stdFile model
            in
                Expect.equal model model_
    ]


moveStdFileTests : List Test
moveStdFileTests =
    [ fuzz (tuple ( int, int )) "file is present on new location" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.stdFile seed1

                stdFileID =
                    getFileId stdFile

                folder =
                    Gen.folder seed2

                destination =
                    getFilePath folder

                maybeDestinationFileID =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile
                        |> addFileRecursively folder
                        |> moveFile destination stdFile
                        |> getFilesOnPath destination
                        |> List.filter (\x -> (getFileId x) == stdFileID)
                        |> List.head
                        |> andJust getFileId
            in
                Expect.equal (Just stdFileID) maybeDestinationFileID
    , fuzz (tuple ( int, int )) "file is absent on old location" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.stdFile seed1

                stdFileID =
                    getFileId stdFile

                folder =
                    Gen.folder seed2

                maybeFile =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile
                        |> addFileRecursively folder
                        |> moveFile (getFilePath folder) stdFile
                        |> getFilesOnPath (getFilePath stdFile)
                        |> List.filter (\x -> (getFileId x) == stdFileID)
                        |> List.head
            in
                Expect.equal maybeFile Nothing
    , fuzz (tuple ( int, int )) "old path is still present" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.stdFile seed1

                folder =
                    Gen.folder seed2

                doesPathExist =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile
                        |> addFileRecursively folder
                        |> moveFile (getFilePath folder) stdFile
                        |> pathExists (getFilePath stdFile)
            in
                Expect.equal True doesPathExist
    ]


moveFolderTests : List Test
moveFolderTests =
    [ fuzz (tuple ( int, int )) "folder is present on new location" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                originFolder =
                    Gen.stdFile seed1

                originFolderID =
                    getFileId originFolder

                destFolder =
                    Gen.folder seed2

                destination =
                    getFilePath destFolder

                maybeDestinationFileId =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively originFolder
                        |> addFileRecursively destFolder
                        |> moveFile destination originFolder
                        |> getFilesOnPath destination
                        |> List.filter (\x -> (getFileId x) == originFolderID)
                        |> List.head
                        |> andJust getFileId
            in
                Expect.equal (Just originFolderID) maybeDestinationFileId

    {- We moved /bar to /foo, so now we have /foo/bar. We need to ensure our
       model recognizes path /foo/bar as valid
    -}
    , fuzz (tuple ( int, int )) "new folder path is added to the model" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                originFolder =
                    Gen.folder seed1

                destFolder =
                    Gen.folder seed2

                destination =
                    getFilePath destFolder

                newPath =
                    destination ++ pathSeparator ++ (getFileName originFolder)

                model =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively originFolder
                        |> addFileRecursively destFolder
                        |> moveFile destination originFolder
            in
                Expect.equal (pathExists newPath model) True
    , fuzz (tuple ( int, int )) "we can move a new file into the moved folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                -- todo: ensureDifferentSeed3
                seed3 =
                    seed2 + 1

                originFolder =
                    Gen.folder seed1

                destFolder =
                    Gen.folder seed2

                destination =
                    getFilePath destFolder

                newPath =
                    destination ++ pathSeparator ++ (getFileName originFolder)

                testFile =
                    seed3
                        |> Gen.stdFile
                        |> setFilePath newPath

                testFileID =
                    getFileId testFile

                maybeFile =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively originFolder
                        |> addFileRecursively destFolder
                        |> moveFile destination originFolder
                        |> addFileRecursively testFile
                        |> addFileRecursively testFile
                        |> getFilesOnPath newPath
                        |> List.filter (\x -> (getFileId x) == testFileID)
                        |> List.head
            in
                Expect.equal maybeFile (Just testFile)
    , fuzz (tuple ( int, int )) "old folder path no longer exists" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                originFolder =
                    Gen.folder seed1

                destFolder =
                    Gen.folder seed2

                destination =
                    getFilePath destFolder

                newPath =
                    destFolder
                        |> getFilePath
                        |> (++) pathSeparator
                        |> (++) (getFileName originFolder)

                doesPathExists =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively originFolder
                        |> addFileRecursively destFolder
                        |> moveFile destination originFolder
                        |> pathExists (getFilePath originFolder)
            in
                Expect.equal doesPathExists False
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
    [ fuzz int "stdfile no longer exists on path" <|
        \seed ->
            let
                stdFile =
                    Gen.stdFile seed

                stdFileID =
                    getFileId stdFile

                maybeFile =
                    seed
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile
                        |> removeFile stdFile
                        |> getFilesOnPath (getFilePath stdFile)
                        |> List.filter (\x -> (getFileId x) == stdFileID)
                        |> List.head
            in
                Expect.equal maybeFile Nothing
    , fuzz int "removed stdfile path still exists" <|
        \seed ->
            let
                stdFile =
                    Gen.stdFile seed

                doesPathExist =
                    seed
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile
                        |> removeFile stdFile
                        |> pathExists (getFilePath stdFile)
            in
                Expect.equal doesPathExist True
    , fuzz
        (tuple ( int, int ))
        "'sister' files still exists on that path"
      <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.stdFile seed1

                path =
                    getFilePath stdFile

                sister =
                    seed2
                        |> Gen.file
                        |> setFilePath path

                sisterID =
                    getFileId sister

                maybeFile =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively stdFile
                        |> addFileRecursively sister
                        |> removeFile stdFile
                        |> getFilesOnPath path
                        |> List.filter (\x -> (getFileId x) == sisterID)
                        |> List.head
            in
                Expect.equal maybeFile (Just sister)
    ]


deleteFolderTests : List Test
deleteFolderTests =
    [ fuzz
        (tuple ( int, int ))
        "wont delete folder when there are files inside"
      <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                folder =
                    Gen.folder seed1

                file =
                    seed2
                        |> Gen.file
                        |> setFilePath (getFilePath folder)

                model =
                    seed1
                        |> Gen.fsRandom
                        |> addFileRecursively folder
                        |> addFileRecursively file

                model_ =
                    removeFile folder model
            in
                Expect.equal model model_
    , fuzz int "folder no longer exists on path" <|
        \seed ->
            let
                folder =
                    Gen.folder seed

                folderID =
                    getFileId folder

                maybeFile =
                    seed
                        |> Gen.fsRandom
                        |> addFileRecursively folder
                        |> removeFile folder
                        |> getFilesOnPath (getFilePath folder)
                        |> List.filter (\x -> (getFileId x) == folderID)
                        |> List.head
            in
                Expect.equal maybeFile Nothing
    , fuzz int "folder path no longer exists" <|
        \seed ->
            let
                folder =
                    Gen.folder seed

                path =
                    getFilePath folder

                model =
                    seed
                        |> Gen.fsRandom
                        |> addFileRecursively folder
                        |> removeFile folder
            in
                Expect.equal (pathExists path model) False
    ]
