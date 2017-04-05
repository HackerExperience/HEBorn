module Gen.Software exposing (..)


import Dict

import Arithmetic exposing (isEven)

import Gen.Utils exposing (..)
import Game.Software.Models exposing (..)


name : Int -> String
name seedInt =
    fuzz1 seedInt nameSeed


nameSeed : StringSeed
nameSeed seed =
    smallStringSeed seed


path : Int -> String
path seedInt =
    fuzz1 seedInt pathSeed


pathSeed : StringSeed
pathSeed seed =
    smallStringSeed seed


extension : Int -> String
extension seedInt =
    fuzz1 seedInt extensionSeed


extensionSeed : StringSeed
extensionSeed seed =
    stringSeed 1 4 seed


folder : Int -> File
folder seedInt =
    let
        (name, path) = fuzz2 seedInt nameSeed pathSeed
    in
        folderArgs
            name path


folderArgs : String -> String -> File
folderArgs name path =
    RegularFolder {name = name, path = path}


regularFile : Int -> File
regularFile seedInt =
    let
        (name, path, extension) = fuzz3 seedInt nameSeed pathSeed extensionSeed
        (version, size) = (fileVersion, fileSize)
    in
        regularFileArgs
            name path extension version size


regularFileArgs : String
         -> FilePath
         -> String
         -> FileVersion
         -> FileSize
         -> File
regularFileArgs name path extension version size =
    RegularFile { name = name
                , path = path
                , extension = extension
                , version = version
                , size = size}


fileVersion : FileVersion
fileVersion =
    FileVersionNumber 10


fileSize : FileSize
fileSize =
    FileSizeNumber 100


fsEmpty: Filesystem
fsEmpty =
    initialFilesystem


model : Int -> SoftwareModel
model seedInt  =
    {filesystem = (fsRandom seedInt)}


file : Int -> File
file seedInt =
    if isEven seedInt then
        regularFile seedInt
    else
        folder seedInt


overwriteFile : (File, Int) -> (File, Int)
overwriteFile oldFile =
    let
        (_, seed) = oldFile
        file_ = file seed
    in
        (file_, seed)


fileList : Int -> List File
fileList seedInt =
    let
        size = Gen.Utils.intRange 10 50 seedInt
        seedList = listOfInt size seedInt
        fileList = List.repeat size (file seedInt)

        list = List.map2 (,) fileList seedList

        (list_, _) = List.unzip (List.map overwriteFile list)
    in
        list_


fsRandom : Int -> Filesystem
fsRandom seedInt =
    let
        list = fileList seedInt
        model = List.foldr
                    (\file model_ -> addFile model_ file)
                    initialSoftwareModel list
    in
        model.filesystem
