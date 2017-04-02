module Gen.Software exposing (..)


import Dict

import Gen.Utils exposing (..)
import Core.Models.Software exposing (..)


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


file : Int -> File
file seedInt =
    let
        (name, path, extension) = fuzz3 seedInt nameSeed pathSeed extensionSeed
        (version, size) = (fileVersion, fileSize)
    in
        fileArgs
            name path extension version size


fileArgs : String
         -> FilePath
         -> String
         -> FileVersion
         -> FileSize
         -> File
fileArgs name path extension version size =
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


createModel : Filesystem -> SoftwareModel
createModel filesystem =
    {filesystem = filesystem}
