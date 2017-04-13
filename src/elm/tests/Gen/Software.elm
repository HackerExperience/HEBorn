module Gen.Software exposing (..)


import Dict

import Arithmetic exposing (isEven)

import Gen.Utils exposing (..)
import Game.Software.Models exposing (..)


fileID : Int -> FileID
fileID seedInt =
    fuzz1 seedInt fileSeed


fileSeed : StringSeed
fileSeed seed =
    smallStringSeed seed


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
        (id, name, path) =
            fuzz3 seedInt fileSeed nameSeed pathSeed
    in
        folderArgs
            id name path


folderArgs : FileID -> String -> String -> File
folderArgs id name path =
    RegularFolder {id = id, name = name, path = path}


regularFile : Int -> File
regularFile seedInt =
    let
        (id, name, path, extension) =
            fuzz4 seedInt fileSeed nameSeed pathSeed extensionSeed
        (version, size) = (fileVersion, fileSize)
    in
        regularFileArgs
            id name path extension version size


regularFileArgs : FileID
         -> String
         -> FilePath
         -> String
         -> FileVersion
         -> FileSize
         -> File
regularFileArgs id name path extension version size =
    RegularFile
    { id = id
    , name = name
    , path = path
    , extension = extension
    , version = version
    , size = size
    }


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
