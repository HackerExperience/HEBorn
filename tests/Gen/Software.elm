module Gen.Software exposing (..)

import Dict
import Arithmetic exposing (isEven)
import Gen.Utils exposing (..)
import Game.Software.Models exposing (..)
import Helper.Software as Helper


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
        ( id, name, path ) =
            fuzz3 seedInt fileSeed nameSeed pathSeed
    in
        folderArgs
            id
            name
            path


folderArgs : FileID -> String -> String -> File
folderArgs id name path =
    Folder { id = id, name = name, path = path }


stdFile : Int -> File
stdFile seedInt =
    let
        ( id, name, path, extension ) =
            fuzz4 seedInt fileSeed nameSeed pathSeed extensionSeed

        ( version, size ) =
            ( fileVersion, fileSize )
    in
        stdFileArgs
            id
            name
            path
            extension
            version
            size
            []


stdFileArgs :
    FileID
    -> String
    -> FilePath
    -> String
    -> FileVersion
    -> FileSize
    -> FileModules
    -> File
stdFileArgs id name path extension version size modules =
    StdFile
        { id = id
        , name = name
        , path = path
        , extension = extension
        , version = version
        , size = size
        , modules = modules
        }


fileVersion : FileVersion
fileVersion =
    FileVersionNumber 10


fileSize : FileSize
fileSize =
    FileSizeNumber 100


fsEmpty : Filesystem
fsEmpty =
    initialFilesystem


model : Int -> SoftwareModel
model seedInt =
    { filesystem = (fsRandom seedInt) }


file : Int -> File
file seedInt =
    if isEven seedInt then
        stdFile seedInt
    else
        folder seedInt


fileList : Int -> List File
fileList seedInt =
    let
        size =
            Gen.Utils.intRange 10 50 seedInt

        seedList =
            listOfInt size seedInt

        fileList =
            List.repeat size (file seedInt)

        list =
            List.map2 (,) fileList seedList

        funOverwrite : ( File, Int ) -> ( File, Int )
        funOverwrite oldFile =
            let
                ( _, seed ) =
                    oldFile

                file_ =
                    file seed
            in
                ( file_, seed )

        ( list_, _ ) =
            List.unzip (List.map funOverwrite list)
    in
        list_


fsRandom : Int -> Filesystem
fsRandom seedInt =
    let
        list =
            fileList seedInt

        model =
            List.foldr
                (\file model_ -> Helper.addFileRecursively model_ file)
                initialSoftwareModel
                list
    in
        model.filesystem
