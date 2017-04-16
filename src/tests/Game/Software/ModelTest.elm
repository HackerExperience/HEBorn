module Game.Software.ModelTest exposing (..)

import Dict
import Expect
import Test exposing (Test, describe)
import Fuzz exposing (int)
import TestUtils exposing (fuzz, once)
import Gen.Software as Gen
import Game.Software.Models exposing (..)
import Gen.Remote


all : Test
all =
    describe "software"
        [ filesystemTests ]


fsBase seed =
    let
        model =
            Gen.model seed

        file =
            Gen.file seed

        model_ =
            addFile model file
    in
        ( model_, file )


filesystemTests : Test
filesystemTests =
    describe "fs"
        [ describe "add file to fs"
            [ fuzz int "path is present" <|
                \seed ->
                    let
                        ( model, file ) =
                            fsBase seed
                    in
                        Expect.equal (pathExists model (getFilePath file)) True
            , fuzz int "file exists on that path" <|
                \seed ->
                    let
                        ( model, file ) =
                            fsBase seed

                        filesOnPath =
                            getFilesOnPath model (getFilePath file)

                        maybeFile =
                            List.head
                                (List.filter
                                    (\x -> (getFileName x) == (getFileName file))
                                    filesOnPath
                                )

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
