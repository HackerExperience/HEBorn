module Core.Models.SoftwareTest exposing (..)


import Dict
import Test exposing (..)
import Expect
import Fuzz exposing (..)

import Gen.Software as Gen
import Core.Models.Software exposing (..)


all : Test
all =
    describe "software"
        [filesystemTests]

filesystemTests : Test
filesystemTests =
    describe "fs"
        [ describe "add folder to fs"
            [ fuzz int  "folder path is present" <|
                  \seed ->
                      let
                          model = Gen.createModel Gen.fsEmpty
                          file = Gen.folder seed
                          model_ = {model | filesystem = (addFileToPath model file)}
                      in
                          Expect.equal (pathExists model_ (getFilePath file)) True

            , fuzz int  "folder exists on that path" <|
                  \seed ->
                      let
                          model = Gen.createModel Gen.fsEmpty
                          file = Gen.folder seed
                          model_ = {model | filesystem = (addFileToPath model file)}
                          filesOnPath = getFilesOnPath model_ (getFilePath file)
                          maybeFile =
                              List.head
                                  (List.filter
                                      (\x -> (getFileName x) == (getFileName file))
                                      filesOnPath)
                          file_ =
                              case maybeFile of
                                  Just file ->
                                      file
                                  Nothing ->
                                      Gen.folder (seed + 1)
                      in
                          Expect.equal file file_
            ]
        , describe "add file to fs"
            [ fuzz int  "file path is present" <|
                  \seed ->
                      let
                          model = Gen.createModel Gen.fsEmpty
                          file = Gen.file seed
                          model_ = {model | filesystem = (addFileToPath model file)}
                      in
                          Expect.equal (pathExists model_ (getFilePath file)) True

            , fuzz int  "file exists on that path" <|
                  \seed ->
                      let
                          model = Gen.createModel Gen.fsEmpty
                          file = Gen.file seed
                          model_ = {model | filesystem = (addFileToPath model file)}
                          filesOnPath = getFilesOnPath model_ (getFilePath file)
                          maybeFile =
                              List.head
                                  (List.filter
                                      (\x -> (getFileName x) == (getFileName file))
                                      filesOnPath)
                          file_ =
                              case maybeFile of
                                  Just file ->
                                      file
                                  Nothing ->
                                      Gen.file (seed + 1)
                      in
                          Expect.equal file file_
            ]
      ]



