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
    [ fuzz Gen.fileEntry "can't add files to non-existing path" <|
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
                    |> Expect.equal initialModel
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
    [ fuzz unit "can't add folder to non-existing path" <|
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
        "file is present on new location"
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
        "file is absent on new location"
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
                    |> Expect.equal False
    ]



--------------------------------------------------------------------------------
-- Delete File
--------------------------------------------------------------------------------


deleteTests : List Test
deleteTests =
    [ describe "delete stdfile"
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
