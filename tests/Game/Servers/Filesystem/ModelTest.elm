module Game.Servers.Filesystem.ModelTest exposing (all)

import Expect
import Gen.Filesystem as Gen
import Fuzz exposing (unit, tuple, tuple3, tuple4)
import Helper.Filesystem as Helper exposing (mkdirp)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, batch)
import Game.Servers.Filesystem.Models exposing (..)


all : Test
all =
    describe "filesystem"
        [ operationsTests
        ]


operationsTests : Test
operationsTests =
    describe "file operations"
        [ describe "insert"
            insertTests
        , describe "move"
            moveTests
        , describe "delete"
            deleteTests
        , describe "scan"
            scanTests
        ]



--------------------------------------------------------------------------------
-- Add File
--------------------------------------------------------------------------------


insertTests : List Test
insertTests =
    [ describe "insert file tests "
        insertFileTests
    , describe "insert folder tests "
        insertFolderTests
    ]


insertFileTests : List Test
insertFileTests =
    [ fuzz Gen.fileEntry "can add files to non-existing path" <|
        \fileEntry ->
            let
                id =
                    toId fileEntry

                file =
                    fileEntry
                        |> toFile
                        |> setPath [ "", "non-existing", "path" ]
            in
                initialModel
                    |> insertFile id file
                    |> Expect.notEqual initialModel
    , fuzz Gen.fileEntry "can add files into existing folders" <|
        \fileEntry ->
            let
                id =
                    toId fileEntry

                file =
                    fileEntry
                        |> toFile
                        |> setPath [ "" ]
            in
                initialModel
                    |> insertFile id file
                    |> isFile (getFullpath file)
                    |> Expect.equal True
    , fuzz
        (tuple3 ( Gen.model, Gen.fileEntry, Gen.fileEntry ))
        "multiple files can exist on the same folder"
      <|
        \( model, fileEntry1, fileEntry2 ) ->
            let
                path =
                    [ "", "example" ]

                id1 =
                    toId fileEntry1

                id2 =
                    toId fileEntry2

                file1 =
                    fileEntry1
                        |> toFile
                        |> setPath path

                file2 =
                    fileEntry2
                        |> toFile
                        |> setPath path

                model_ =
                    model
                        |> mkdirp path
                        |> insertFile id1 file1
                        |> insertFile id2 file2

                fileExists =
                    getFullpath
                        >> flip isFile model_
                        >> Expect.equal True
            in
                batch
                    [ fileExists file1
                    , fileExists file2
                    ]
    ]


insertFolderTests : List Test
insertFolderTests =
    [ fuzz unit "can add folder to non-existing paths" <|
        \() ->
            initialModel
                |> insertFolder [ "", "non-existing" ] "path"
                |> Expect.equal initialModel
    , fuzz unit "can add folder into existing folders" <|
        \() ->
            initialModel
                |> insertFolder [ "" ] "example"
                |> Expect.notEqual initialModel
    , fuzz
        (tuple3 ( Gen.model, Gen.folder, Gen.folder ))
        "multiple folders can exist on the same folder"
      <|
        \( model, folder1, folder2 ) ->
            let
                insertFolder_ =
                    uncurry insertFolder

                model_ =
                    model
                        |> insertFolder_ folder1
                        |> insertFolder_ folder2

                expectIsDirectory =
                    uncurry (flip appendPath)
                        >> flip isFolder model_
                        >> Expect.equal True
            in
                batch
                    [ expectIsDirectory folder1
                    , expectIsDirectory folder2
                    ]
    ]



--------------------------------------------------------------------------------
-- Move File
--------------------------------------------------------------------------------


moveTests : List Test
moveTests =
    [ describe "move file around"
        moveFileTests
    ]


moveFileTests : List Test
moveFileTests =
    [ fuzz (tuple3 ( Gen.model, Gen.fileEntry, Gen.folder ))
        "can move file to existing path"
      <|
        \( model, fileEntry, ( path, name ) ) ->
            let
                path_ =
                    appendPath name path

                id =
                    toId fileEntry

                file =
                    toFile fileEntry

                model_ =
                    model
                        |> insertFile id file
                        |> mkdirp path_
            in
                model_
                    |> isFile (getFullpath file)
                    |> Expect.equal True
    , fuzz (tuple3 ( Gen.model, Gen.fileEntry, Gen.folder ))
        "can move file to non-existing path"
      <|
        \( model, fileEntry, ( path, name ) ) ->
            let
                path_ =
                    appendPath name path

                id =
                    toId fileEntry

                file =
                    fileEntry
                        |> toFile
                        |> setPath path_
            in
                model
                    |> insertFile id file
                    |> isFile (getFullpath file)
                    |> Expect.equal True
    ]



--------------------------------------------------------------------------------
-- Delete File
--------------------------------------------------------------------------------


deleteTests : List Test
deleteTests =
    [ describe "delete file"
        deleteFileTests
    , describe "delete folder"
        deleteFolderTests
    ]


deleteFileTests : List Test
deleteFileTests =
    [ fuzz
        (tuple ( Gen.model, Gen.fileEntry ))
        "file no longer exists on path"
      <|
        \( model, fileEntry ) ->
            let
                id =
                    toId fileEntry

                file =
                    toFile fileEntry

                model_ =
                    model
                        |> insertFile id file
                        |> deleteFile id
            in
                model_
                    |> getFile id
                    |> Expect.equal Nothing
    ]


deleteFolderTests : List Test
deleteFolderTests =
    [ fuzz
        (tuple ( Gen.model, Gen.fileEntry ))
        "won't delete folder when there are files inside"
      <|
        \( model, fileEntry ) ->
            let
                id =
                    toId fileEntry

                file =
                    toFile fileEntry

                model_ =
                    insertFile id file model
            in
                model_
                    |> deleteFolder (getPath file)
                    |> Expect.equal model_
    , fuzz (tuple ( Gen.model, Gen.folder )) "folder path no longer exists" <|
        \( model, ( path, name ) ) ->
            let
                path_ =
                    appendPath name path

                model_ =
                    model
                        |> insertFolder path name
                        |> deleteFolder path_
            in
                model_
                    |> isFolder path_
                    |> Expect.equal False
    ]



--------------------------------------------------------------------------------
-- Add File
--------------------------------------------------------------------------------


scanTests : List Test
scanTests =
    -- hardcoded tests to make it easier to understand what's happening
    [ describe "scan path"
        scanPathTests
    , describe "list path"
        listPathTests
    ]


scanPathTests : List Test
scanPathTests =
    [ fuzz unit "scan includes nested files" <|
        \() ->
            let
                file1 =
                    File "file1" "txt" [ "" ] 0 Text

                file2 =
                    File "file2" "txt" [ "", "folder1" ] 0 Text

                file3 =
                    File "file3" "txt" [ "", "folder1", "folder2" ] 0 Text

                entries =
                    initialModel
                        |> insertFile "id1" file1
                        |> insertFile "id2" file2
                        |> insertFile "id3" file3
                        |> scan [ "" ]

                expectFiles =
                    [ FileEntry "id3" file3
                    , FileEntry "id2" file2
                    , FileEntry "id1" file1
                    ]

                expectFolders =
                    [ FolderEntry [ "", "folder1" ] "folder2"
                    , FolderEntry [ "" ] "folder1"
                    ]
            in
                batch
                    [ Expect.equal expectFiles <|
                        List.filter (isFolderEntry >> not) entries
                    , Expect.equal expectFolders <|
                        List.filter isFolderEntry entries
                    ]
    , fuzz unit "scan won't include files from unrelated paths" <|
        \() ->
            let
                file1 =
                    File "file1" "txt" [ "", "folder1" ] 0 Text

                file2 =
                    File "file2" "txt" [ "", "folder1", "folder2" ] 0 Text

                file3 =
                    File "file3" "txt" [ "", "folder2" ] 0 Text

                entries =
                    initialModel
                        |> insertFile "id1" file1
                        |> insertFile "id2" file2
                        |> insertFile "id3" file3
                        |> scan [ "", "folder1" ]

                expectFiles =
                    [ FileEntry "id2" file2
                    , FileEntry "id1" file1
                    ]

                expectFolders =
                    [ FolderEntry [ "", "folder1" ] "folder2" ]
            in
                batch
                    [ Expect.equal expectFiles <|
                        List.filter (isFolderEntry >> not) entries
                    , Expect.equal expectFolders <|
                        List.filter isFolderEntry entries
                    ]
    , fuzz unit "scan include files from detached paths" <|
        \() ->
            let
                file =
                    File "file" "txt" [ "", "folder1", "folder2" ] 0 Text

                entries =
                    initialModel
                        |> insertFile "id" file
                        |> scan [ "" ]

                expectFiles =
                    [ FileEntry "id" file
                    ]

                expectFolders =
                    [ FolderEntry [ "", "folder1" ] "folder2" ]
            in
                batch
                    [ Expect.equal expectFiles <|
                        List.filter (isFolderEntry >> not) entries
                    , Expect.equal expectFolders <|
                        List.filter isFolderEntry entries
                    ]
    ]


listPathTests : List Test
listPathTests =
    [ fuzz unit "list includes nested files" <|
        \() ->
            let
                file1 =
                    File "file1" "txt" [ "" ] 0 Text

                file2 =
                    File "file2" "txt" [ "", "folder1" ] 0 Text

                file3 =
                    File "file3" "txt" [ "", "folder1", "folder2" ] 0 Text

                entries =
                    initialModel
                        |> insertFile "id1" file1
                        |> insertFile "id2" file2
                        |> insertFile "id3" file3
                        |> list [ "" ]

                expectFiles =
                    [ FileEntry "id1" file1
                    ]

                expectFolders =
                    [ FolderEntry [ "" ] "folder1"
                    ]
            in
                batch
                    [ Expect.equal expectFiles <|
                        List.filter (isFolderEntry >> not) entries
                    , Expect.equal expectFolders <|
                        List.filter isFolderEntry entries
                    ]
    , fuzz unit "list won't include files from unrelated paths" <|
        \() ->
            let
                file1 =
                    File "file1" "txt" [ "", "folder1" ] 0 Text

                file2 =
                    File "file2" "txt" [ "", "folder1", "folder2" ] 0 Text

                file3 =
                    File "file3" "txt" [ "", "folder2" ] 0 Text

                entries =
                    initialModel
                        |> insertFile "id1" file1
                        |> insertFile "id2" file2
                        |> insertFile "id3" file3
                        |> list [ "", "folder1" ]

                expectFiles =
                    [ FileEntry "id1" file1
                    ]

                expectFolders =
                    [ FolderEntry [ "", "folder1" ] "folder2" ]
            in
                batch
                    [ Expect.equal expectFiles <|
                        List.filter (isFolderEntry >> not) entries
                    , Expect.equal expectFolders <|
                        List.filter isFolderEntry entries
                    ]
    , fuzz unit "list includes detached folders" <|
        \() ->
            let
                file =
                    File "file" "txt" [ "", "folder1", "folder2" ] 0 Text

                entries =
                    initialModel
                        |> insertFile "id" file
                        |> list [ "" ]

                noFiles =
                    entries
                        |> List.filter (isFolderEntry >> not)
                        |> List.isEmpty

                expectFolders =
                    [ FolderEntry [ "", "folder1" ] "folder2" ]
            in
                batch
                    [ Expect.equal True noFiles
                    , Expect.equal expectFolders <|
                        List.filter isFolderEntry entries
                    ]
    ]
