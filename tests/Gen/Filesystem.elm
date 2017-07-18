module Gen.Filesystem exposing (..)

-- !important
-- TODO: Update this to generate files and folders outside of Root

import Fuzz exposing (Fuzzer)
import Random.Pcg
    exposing
        ( Generator
        , constant
        , int
        , list
        , choices
        , map
        , andThen
        )
import Random.Pcg.Extra exposing (andMap)
import Gen.Utils exposing (fuzzer, unique, stringRange, listRange)
import Game.Servers.Filesystem.Models exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)
import Helper.Filesystem exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


fileID : Fuzzer FileID
fileID =
    fuzzer genFileID


name : Fuzzer String
name =
    fuzzer genName


location : Fuzzer Location
location =
    fuzzer genLocation


extension : Fuzzer String
extension =
    fuzzer genExtension


noSize : Fuzzer FileSize
noSize =
    fuzzer genNoSize


fileSizeNumber : Fuzzer FileSize
fileSizeNumber =
    fuzzer genFileSizeNumber


fileSize : Fuzzer FileSize
fileSize =
    fuzzer genFileSize


noVersion : Fuzzer FileVersion
noVersion =
    fuzzer genNoVersion


fileVersionNumber : Fuzzer FileVersion
fileVersionNumber =
    fuzzer genFileVersionNumber


fileVersion : Fuzzer FileVersion
fileVersion =
    fuzzer genFileVersion


folder : Fuzzer Entry
folder =
    fuzzer genFolder


file : Fuzzer Entry
file =
    fuzzer genFile


entry : Fuzzer Entry
entry =
    fuzzer genEntry


entryList : Fuzzer (List Entry)
entryList =
    fuzzer genEntryList


emptyFilesystem : Fuzzer Filesystem
emptyFilesystem =
    fuzzer genEmptyFilesystem


nonEmptyFilesystem : Fuzzer Filesystem
nonEmptyFilesystem =
    fuzzer genNonEmptyFilesystem


filesystem : Fuzzer Filesystem
filesystem =
    fuzzer genFilesystem


model : Fuzzer Filesystem
model =
    fuzzer genModel



--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------


genFileID : Generator FileID
genFileID =
    unique


genName : Generator String
genName =
    stringRange 1 24


genLocation : Generator Location
genLocation =
    stringRange 3 16
        |> listRange 1 10


genExtension : Generator String
genExtension =
    stringRange 1 8


genNoSize : Generator FileSize
genNoSize =
    constant Nothing


genFileSizeNumber : Generator FileSize
genFileSizeNumber =
    map Just (int 1 32768)


genFileSize : Generator FileSize
genFileSize =
    choices [ genNoSize, genFileSizeNumber ]


genNoVersion : Generator FileVersion
genNoVersion =
    constant Nothing


genFileVersionNumber : Generator FileVersion
genFileVersionNumber =
    map Just (int 1 999)


genFileVersion : Generator FileVersion
genFileVersion =
    choices [ genNoVersion, genFileVersionNumber ]


genFolder : Generator Entry
genFolder =
    let
        buildFolderRecord =
            \id name ->
                FolderEntry
                    { id = id
                    , name = name
                    , parent = RootRef
                    }
    in
        genFileID
            |> map buildFolderRecord
            |> andMap genName


genFile : Generator Entry
genFile =
    let
        buildStdFileRecord =
            \id name extension version size ->
                FileEntry
                    { id = id
                    , name = name
                    , parent = RootRef
                    , extension = extension
                    , version = version
                    , size = size
                    , modules = []
                    }
    in
        genFileID
            |> map buildStdFileRecord
            |> andMap genName
            |> andMap genExtension
            |> andMap genFileVersion
            |> andMap genFileSize


genEntry : Generator Entry
genEntry =
    choices [ genFolder, genFile ]


genEntryList : Generator (List Entry)
genEntryList =
    andThen ((flip list) (genEntry)) (int 1 32)


genEmptyFilesystem : Generator Filesystem
genEmptyFilesystem =
    constant initialFilesystem


genNonEmptyFilesystem : Generator Filesystem
genNonEmptyFilesystem =
    genFileID
        |> map
            (\fileID location entryList ->
                List.foldl
                    (\f fs ->
                        fs
                            |> addEntry f
                            |> moveEntry ( location, getEntryBasename f ) f
                    )
                    (initialFilesystem
                        |> createLocation fileID location
                    )
                    entryList
            )
        |> andMap genLocation
        |> andMap genEntryList


genFilesystem : Generator Filesystem
genFilesystem =
    choices [ genEmptyFilesystem, genNonEmptyFilesystem ]


genModel : Generator Filesystem
genModel =
    genFilesystem
