module Game.Software.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Gen.Software as Gen
import Helper.Software as Helper exposing (addFileRecursively)
import Game.Software.Models exposing (..)
import Gen.Remote


all : Test
all =
    describe "software"
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

                stdFile =
                    Gen.stdFile seed1

                model =
                    Gen.model seed1

                model_ =
                    addFile model stdFile
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

                model =
                    Gen.model seed1

                model_ =
                    addFileRecursively model stdFile

                filesOnPath =
                    getFilesOnPath model_ (getFilePath stdFile)

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId stdFile))
                            filesOnPath
                        )
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
                    Gen.model seed2

                model_ =
                    addFileRecursively model folder
            in
                Expect.equal (pathExists model_ (getFilePath folder)) True
    , fuzz (tuple ( int, int )) "multiple files can exist on the same folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                folder =
                    setFilePath (Gen.folder seed1) (Gen.path (seed1 + 1))

                model =
                    Gen.model seed1

                path =
                    getFilePath folder

                file1 =
                    setFilePath (Gen.stdFile seed2) path

                file2 =
                    setFilePath (Gen.stdFile (seed2 + 1)) path

                model1 =
                    addFile model folder

                model2 =
                    addFile model1 file1

                model_ =
                    addFile model2 file2

                filesOnPath =
                    getFilesOnPath model_ path

                f =
                    Debug.log "on path" (toString (getFilesOnPath model_ path))
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

                model1 =
                    addFileRecursively (Gen.model seed1) stdFile

                model_ =
                    moveFile model1 stdFile destination
            in
                Expect.equal model_ model1
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

                folder =
                    Gen.folder seed2

                destination =
                    getFilePath folder

                model1 =
                    addFileRecursively (Gen.model seed1) stdFile

                model2 =
                    addFileRecursively model1 folder

                model_ =
                    moveFile model2 stdFile destination

                filesOnPath =
                    getFilesOnPath model_ destination

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId stdFile))
                            filesOnPath
                        )

                destinationFileId =
                    case maybeFile of
                        Just file ->
                            getFileId file

                        Nothing ->
                            "invalidid"
            in
                Expect.equal destinationFileId (getFileId stdFile)
    , fuzz (tuple ( int, int )) "file is absent on old location" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                stdFile =
                    Gen.stdFile seed1

                folder =
                    Gen.folder seed2

                origin =
                    getFilePath stdFile

                model1 =
                    addFileRecursively (Gen.model seed1) stdFile

                model2 =
                    addFileRecursively model1 folder

                model_ =
                    moveFile model2 stdFile (getFilePath folder)

                filesOnPath =
                    getFilesOnPath model_ origin

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId stdFile))
                            filesOnPath
                        )
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

                origin =
                    getFilePath stdFile

                model1 =
                    addFileRecursively (Gen.model seed1) stdFile

                model2 =
                    addFileRecursively model1 folder

                model_ =
                    moveFile model2 stdFile (getFilePath folder)
            in
                Expect.equal (pathExists model_ origin) True
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

                destFolder =
                    Gen.folder seed2

                destination =
                    getFilePath destFolder

                model1 =
                    addFileRecursively (Gen.model seed1) originFolder

                model2 =
                    addFileRecursively model1 destFolder

                model_ =
                    moveFile model2 originFolder destination

                filesOnPath =
                    getFilesOnPath model_ destination

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId originFolder))
                            filesOnPath
                        )

                destinationFileId =
                    case maybeFile of
                        Just file ->
                            getFileId file

                        Nothing ->
                            "invalidid"
            in
                Expect.equal destinationFileId (getFileId originFolder)

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

                model1 =
                    addFileRecursively (Gen.model seed1) originFolder

                model2 =
                    addFileRecursively model1 destFolder

                model_ =
                    moveFile model2 originFolder destination

                newPath =
                    destination ++ pathSeparator ++ (getFileName originFolder)
            in
                Expect.equal (pathExists model_ newPath) True
    , fuzz (tuple ( int, int )) "we can move a new file into the moved folder" <|
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

                -- todo: ensureDifferentSeed3
                testFile =
                    setFilePath (Gen.stdFile (seed2 + 1)) newPath

                model1 =
                    addFileRecursively (Gen.model seed1) originFolder

                model2 =
                    addFileRecursively model1 destFolder

                model3 =
                    moveFile model2 originFolder destination

                model4 =
                    addFileRecursively model3 testFile

                model_ =
                    addFileRecursively model4 testFile

                filesOnPath =
                    getFilesOnPath model_ newPath

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId testFile))
                            filesOnPath
                        )
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

                origin =
                    getFilePath originFolder

                destination =
                    getFilePath destFolder

                newPath =
                    destination ++ "/" ++ (getFileName originFolder)

                model1 =
                    addFileRecursively (Gen.model seed1) originFolder

                model2 =
                    addFileRecursively model1 destFolder

                model_ =
                    moveFile model2 originFolder destination
            in
                Expect.equal (pathExists model_ origin) False
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

                model =
                    addFileRecursively (Gen.model seed) stdFile

                model_ =
                    removeFile model stdFile

                filesOnPath =
                    getFilesOnPath model_ (getFilePath stdFile)

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId stdFile))
                            filesOnPath
                        )
            in
                Expect.equal maybeFile Nothing
    , fuzz int "removed stdfile path still exists" <|
        \seed ->
            let
                stdFile =
                    Gen.stdFile seed

                model =
                    addFileRecursively (Gen.model seed) stdFile

                path =
                    getFilePath stdFile

                model_ =
                    removeFile model stdFile
            in
                Expect.equal (pathExists model_ path) True
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
                    setFilePath (Gen.file seed2) path

                model1 =
                    addFileRecursively (Gen.model seed1) stdFile

                model2 =
                    addFileRecursively model1 sister

                model_ =
                    removeFile model2 stdFile

                filesOnPath =
                    getFilesOnPath model_ path

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId sister))
                            filesOnPath
                        )
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
                    Gen.file seed2

                file_ =
                    setFilePath file (getFilePath folder)

                model1 =
                    addFileRecursively (Gen.model seed1) folder

                model2 =
                    addFileRecursively model1 file_

                model_ =
                    removeFile model2 folder
            in
                Expect.equal model2 model_
    , fuzz int "folder no longer exists on path" <|
        \seed ->
            let
                folder =
                    Gen.folder seed

                model =
                    addFileRecursively (Gen.model seed) folder

                model_ =
                    removeFile model folder

                filesOnPath =
                    getFilesOnPath model_ (getFilePath folder)

                maybeFile =
                    List.head
                        (List.filter
                            (\x -> (getFileId x) == (getFileId folder))
                            filesOnPath
                        )
            in
                Expect.equal maybeFile Nothing
    , fuzz int "folder path no longer exists" <|
        \seed ->
            let
                folder =
                    Gen.folder seed

                model =
                    addFileRecursively (Gen.model seed) folder

                path =
                    getFilePath folder

                model_ =
                    removeFile model folder
            in
                Expect.equal (pathExists model_ path) False
    ]
