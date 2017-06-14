module Gen.Filesystem exposing (..)

import Fuzz exposing (Fuzzer)
import Gen.Utils exposing (fuzzer, unique, stringRange, listRange)
import Helper.Filesystem exposing (addFileRecursively)
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
import Game.Servers.Filesystem.Models exposing (..)


--------------------------------------------------------------------------------
-- Fuzzers
--------------------------------------------------------------------------------


fileID : Fuzzer FileID
fileID =
    fuzzer genFileID


name : Fuzzer String
name =
    fuzzer genName


path : Fuzzer String
path =
    fuzzer genPath


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


folder : Fuzzer File
folder =
    fuzzer genFolder


stdFile : Fuzzer File
stdFile =
    fuzzer genStdFile


file : Fuzzer File
file =
    fuzzer genFile


fileList : Fuzzer (List File)
fileList =
    fuzzer genFileList


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


genPath : Generator String
genPath =
    stringRange 3 16
        |> listRange 1 10
        |> map (\paths -> "/" ++ (String.join "/" paths))


genExtension : Generator String
genExtension =
    stringRange 1 8


genNoSize : Generator FileSize
genNoSize =
    constant NoSize


genFileSizeNumber : Generator FileSize
genFileSizeNumber =
    map FileSizeNumber (int 1 32768)


genFileSize : Generator FileSize
genFileSize =
    choices [ genNoSize, genFileSizeNumber ]


genNoVersion : Generator FileVersion
genNoVersion =
    constant NoVersion


genFileVersionNumber : Generator FileVersion
genFileVersionNumber =
    map FileVersionNumber (int 1 999)


genFileVersion : Generator FileVersion
genFileVersion =
    choices [ genNoVersion, genFileVersionNumber ]


genFolder : Generator File
genFolder =
    let
        buildFolderRecord =
            \id name path ->
                Folder
                    { id = id
                    , name = name
                    , path = path
                    }
    in
        genFileID
            |> map buildFolderRecord
            |> andMap genName
            |> andMap genPath


genStdFile : Generator File
genStdFile =
    let
        buildStdFileRecord =
            \id name path extension version size ->
                StdFile
                    { id = id
                    , name = name
                    , path = path
                    , extension = extension
                    , version = version
                    , size = size
                    , modules = []
                    }
    in
        genFileID
            |> map buildStdFileRecord
            |> andMap genName
            |> andMap genPath
            |> andMap genExtension
            |> andMap genFileVersion
            |> andMap genFileSize


genFile : Generator File
genFile =
    choices [ genFolder, genStdFile ]


genFileList : Generator (List File)
genFileList =
    andThen ((flip list) genFile) (int 1 32)


genEmptyFilesystem : Generator Filesystem
genEmptyFilesystem =
    constant initialFilesystem


genNonEmptyFilesystem : Generator Filesystem
genNonEmptyFilesystem =
    List.foldl
        addFileRecursively
        initialFilesystem
        >> constant
        |> (flip andThen) genFileList


genFilesystem : Generator Filesystem
genFilesystem =
    choices [ genEmptyFilesystem, genNonEmptyFilesystem ]


genModel : Generator Filesystem
genModel =
    genFilesystem
