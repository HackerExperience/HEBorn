module Game.Servers.Filesystem.ModelTest exposing (all)

import Expect
import Gen.Filesystem as Gen
import Fuzz exposing (int, tuple, tuple3, tuple4)
import Helper.Filesystem as Helper exposing (addFileRecursively)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, once, ensureDifferentSeed)
import Utils exposing (andJust)
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
        (tuple ( Gen.model, Gen.stdFile ))
        "can't add stdfile to non-existing path (no recursive)"
      <|
        \( model, file ) ->
            model
                |> addFile file
                |> Expect.equal model
    , fuzz
        (tuple ( Gen.model, Gen.stdFile ))
        "can add stdfile to non-existing path (recursively)"
      <|
        \( filesystem, file ) ->
            let
                fileID =
                    getFileId file

                model =
                    addFileRecursively file filesystem
            in
                file
                    |> getFilePath
                    |> (flip getFilesOnPath) model
                    |> List.filter (\x -> (getFileId x) == fileID)
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
            model
                |> addFileRecursively folder
                |> pathExists (getFilePath folder)
                |> Expect.equal True
    , fuzz
        (tuple4 ( Gen.model, Gen.folder, Gen.stdFile, Gen.stdFile ))
        "multiple files can exist on the same folder"
      <|
        \( model, folder, file1, file2 ) ->
            let
                path =
                    getFilePath folder

                file1_ =
                    setFilePath path file1

                file2_ =
                    setFilePath path file2
            in
                model
                    |> addFile folder
                    |> addFile file1_
                    |> addFile file2_
                    |> getFilesOnPath path
                    |> Expect.equal ([ folder, file1_, file2_ ])
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
        (tuple3 ( Gen.model, Gen.file, Gen.path ))
        "can't move file to non-existing path"
      <|
        \( filesystem, file, destination ) ->
            let
                model =
                    addFileRecursively file filesystem
            in
                model
                    |> moveFile destination file
                    |> Expect.equal model
    ]


moveStdFileTests : List Test
moveStdFileTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.stdFile, Gen.folder ))
        "file is present on new location"
      <|
        \( model, file, folder ) ->
            let
                fileID =
                    getFileId file

                destination =
                    getFilePath folder
            in
                model
                    |> addFileRecursively file
                    |> addFileRecursively folder
                    |> moveFile destination file
                    |> getFilesOnPath destination
                    |> List.filter (\x -> (getFileId x) == fileID)
                    |> List.head
                    |> andJust getFileId
                    |> Expect.equal (Just fileID)
    , fuzz
        (tuple3 ( Gen.model, Gen.stdFile, Gen.folder ))
        "file is absent on old location"
      <|
        \( model, file, folder ) ->
            let
                fileID =
                    getFileId file
            in
                model
                    |> addFileRecursively file
                    |> addFileRecursively folder
                    |> moveFile (getFilePath folder) file
                    |> getFilesOnPath (getFilePath file)
                    |> List.filter (\x -> (getFileId x) == fileID)
                    |> List.head
                    |> Expect.equal Nothing
    , fuzz
        (tuple3 ( Gen.model, Gen.stdFile, Gen.folder ))
        "old path is still present"
      <|
        \( model, file, folder ) ->
            model
                |> addFileRecursively file
                |> addFileRecursively folder
                |> moveFile (getFilePath folder) file
                |> pathExists (getFilePath file)
                |> Expect.equal True
    ]


moveFolderTests : List Test
moveFolderTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.file, Gen.folder ))
        "folder is present on new location"
      <|
        \( model, file, folder ) ->
            let
                fileID =
                    getFileId file

                destination =
                    getFilePath folder
            in
                model
                    |> addFileRecursively file
                    |> addFileRecursively folder
                    |> moveFile destination file
                    |> getFilesOnPath destination
                    |> List.filter (\x -> (getFileId x) == fileID)
                    |> List.head
                    |> andJust getFileId
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
                destination =
                    getFilePath target

                newPath =
                    destination ++ pathSeparator ++ (getFileName origin)
            in
                model
                    |> addFileRecursively origin
                    |> addFileRecursively target
                    |> moveFile destination origin
                    |> pathExists newPath
                    |> Expect.equal True
    , fuzz
        (tuple4 ( Gen.model, Gen.file, Gen.folder, Gen.folder ))
        "we can move a new file into the moved folder"
      <|
        \( model, file, folder1, folder2 ) ->
            let
                destination =
                    getFilePath folder2

                newPath =
                    destination ++ pathSeparator ++ (getFileName folder1)

                fileID =
                    getFileId file

                file_ =
                    setFilePath newPath file
            in
                model
                    |> addFileRecursively folder1
                    |> addFileRecursively folder2
                    |> moveFile destination folder1
                    |> addFileRecursively file_
                    |> addFileRecursively file_
                    |> getFilesOnPath newPath
                    |> List.filter (\x -> (getFileId x) == fileID)
                    |> List.head
                    |> Expect.equal (Just file_)
    , fuzz
        (tuple3 ( Gen.model, Gen.folder, Gen.folder ))
        "old folder path no longer exists"
      <|
        \( model, folder1, folder2 ) ->
            let
                destination =
                    getAbsolutePath folder2
            in
                model
                    |> addFileRecursively folder1
                    |> addFileRecursively folder2
                    |> moveFile destination folder1
                    |> pathExists (getAbsolutePath folder1)
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
        (tuple ( Gen.model, Gen.stdFile ))
        "stdfile no longer exists on path"
      <|
        \( model, file ) ->
            let
                fileID =
                    getFileId file
            in
                model
                    |> addFileRecursively file
                    |> removeFile file
                    |> getFilesOnPath (getFilePath file)
                    |> List.filter (\x -> (getFileId x) == fileID)
                    |> List.head
                    |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.model, Gen.stdFile ))
        "removed stdfile path still exists"
      <|
        \( model, file ) ->
            model
                |> addFileRecursively file
                |> removeFile file
                |> pathExists (getFilePath file)
                |> Expect.equal True
    , fuzz
        (tuple3 ( Gen.model, Gen.stdFile, Gen.stdFile ))
        "'sister' files still exists on that path"
      <|
        \( model, file, file2 ) ->
            let
                path =
                    getFilePath file

                sister =
                    setFilePath path file2

                sisterID =
                    getFileId sister
            in
                model
                    |> addFileRecursively file
                    |> addFileRecursively sister
                    |> removeFile file
                    |> getFilesOnPath path
                    |> List.filter (\x -> (getFileId x) == sisterID)
                    |> List.head
                    |> Expect.equal (Just sister)
    ]


deleteFolderTests : List Test
deleteFolderTests =
    [ fuzz
        (tuple3 ( Gen.model, Gen.file, Gen.folder ))
        "won't delete folder when there are files inside"
      <|
        \( filesystem, file, folder ) ->
            let
                file_ =
                    setFilePath (getAbsolutePath folder) file

                model =
                    filesystem
                        |> addFileRecursively folder
                        |> addFileRecursively file_
            in
                model
                    |> removeFile folder
                    |> Expect.equal model
    , fuzz
        (tuple ( Gen.model, Gen.folder ))
        "folder no longer exists on path"
      <|
        \( model, folder ) ->
            let
                folderID =
                    getFileId folder
            in
                model
                    |> addFileRecursively folder
                    |> removeFile folder
                    |> getFilesOnPath (getFilePath folder)
                    |> List.filter (\x -> (getFileId x) == folderID)
                    |> List.head
                    |> Expect.equal Nothing
    , fuzz
        (tuple ( Gen.model, Gen.folder ))
        "folder path no longer exists"
      <|
        \( model, folder ) ->
            model
                |> addFileRecursively folder
                |> removeFile folder
                |> pathExists (getAbsolutePath folder)
                |> Expect.equal False
    ]
