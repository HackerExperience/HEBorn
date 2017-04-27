module Game.Servers.Filesystem.ModelTest exposing (all)

import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int, tuple)
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

                stdFile =
                    Gen.stdFile seed1

                model =
                    Gen.model seed1

                model_ =
                    addFile stdFile model
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
                    addFileRecursively stdFile model

                filesOnPath =
                    getFilesOnPath (getFilePath stdFile) model_

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
                    addFileRecursively folder model
            in
                Expect.equal (pathExists (getFilePath folder) model_) True
    , fuzz (tuple ( int, int )) "multiple files can exist on the same folder" <|
        \seed ->
            let
                ( seed1, seed2 ) =
                    ensureDifferentSeed seed

                folder =
                    setFilePath (Gen.path (seed1 + 1)) (Gen.folder seed1)

                model =
                    Gen.model seed1

                path =
                    getFilePath folder

                file1 =
                    setFilePath path (Gen.stdFile seed2)

                file2 =
                    setFilePath path (Gen.stdFile (seed2 + 1))

                model1 =
                    addFile folder model

                model2 =
                    addFile file1 model1

                model_ =
                    addFile file2 model2

                filesOnPath =
                    getFilesOnPath path model_
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
                    addFileRecursively stdFile (Gen.model seed1)

                model_ =
                    moveFile destination stdFile model1
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
                    addFileRecursively stdFile (Gen.model seed1)

                model2 =
                    addFileRecursively folder model1

                model_ =
                    moveFile destination stdFile model2

                filesOnPath =
                    getFilesOnPath destination model_

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
                    addFileRecursively stdFile (Gen.model seed1)

                model2 =
                    addFileRecursively folder model1

                model_ =
                    moveFile (getFilePath folder) stdFile model2

                filesOnPath =
                    getFilesOnPath origin model_

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
                    addFileRecursively stdFile (Gen.model seed1)

                model2 =
                    addFileRecursively folder model1

                model_ =
                    moveFile (getFilePath folder) stdFile model2
            in
                Expect.equal (pathExists origin model_) True
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
                    addFileRecursively originFolder (Gen.model seed1)

                model2 =
                    addFileRecursively destFolder model1

                model_ =
                    moveFile destination originFolder model2

                filesOnPath =
                    getFilesOnPath destination model_

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
                    addFileRecursively originFolder (Gen.model seed1)

                model2 =
                    addFileRecursively destFolder model1

                model_ =
                    moveFile destination originFolder model2

                newPath =
                    destination ++ pathSeparator ++ (getFileName originFolder)
            in
                Expect.equal (pathExists newPath model_) True
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
                    setFilePath newPath (Gen.stdFile (seed2 + 1))

                model1 =
                    addFileRecursively originFolder (Gen.model seed1)

                model2 =
                    addFileRecursively destFolder model1

                model3 =
                    moveFile destination originFolder model2

                model4 =
                    addFileRecursively testFile model3

                model_ =
                    addFileRecursively testFile model4

                filesOnPath =
                    getFilesOnPath newPath model_

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
                    destination ++ pathSeparator ++ (getFileName originFolder)

                model1 =
                    addFileRecursively originFolder (Gen.model seed1)

                model2 =
                    addFileRecursively destFolder model1

                model_ =
                    moveFile destination originFolder model2
            in
                Expect.equal (pathExists origin model_) False
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
                    addFileRecursively stdFile (Gen.model seed)

                model_ =
                    removeFile stdFile model

                filesOnPath =
                    getFilesOnPath (getFilePath stdFile) model_

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
                    addFileRecursively stdFile (Gen.model seed)

                path =
                    getFilePath stdFile

                model_ =
                    removeFile stdFile model
            in
                Expect.equal (pathExists path model_) True
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
                    setFilePath path (Gen.file seed2)

                model1 =
                    addFileRecursively stdFile (Gen.model seed1)

                model2 =
                    addFileRecursively sister model1

                model_ =
                    removeFile stdFile model2

                filesOnPath =
                    getFilesOnPath path model_

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
                    setFilePath (getFilePath folder) file

                model1 =
                    addFileRecursively folder (Gen.model seed1)

                model2 =
                    addFileRecursively file_ model1

                model_ =
                    removeFile folder model2
            in
                Expect.equal model2 model_
    , fuzz int "folder no longer exists on path" <|
        \seed ->
            let
                folder =
                    Gen.folder seed

                model =
                    addFileRecursively folder (Gen.model seed)

                model_ =
                    removeFile folder model

                filesOnPath =
                    getFilesOnPath (getFilePath folder) model_

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
                    addFileRecursively folder (Gen.model seed)

                path =
                    getFilePath folder

                model_ =
                    removeFile folder model
            in
                Expect.equal (pathExists path model_) False
    ]
