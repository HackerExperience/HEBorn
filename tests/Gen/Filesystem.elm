module Gen.Filesystem exposing (..)

import Dict
import Arithmetic exposing (isEven)
import Gen.Utils exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Helper.Filesystem as Helper


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
    let
        ( level, seed1 ) =
            intRangeSeed 1 10 seed

        ( path, s ) =
            smallStringSeed seed1

        ( seedList, seed2 ) =
            listOfSeed level seed1

        directoryList =
            List.repeat level ""

        list =
            List.map2 (,) directoryList seedList

        funOverwrite : ( FilePath, Seed ) -> ( FilePath, Seed )
        funOverwrite item =
            let
                ( _, seed_ ) =
                    item

                ( directory_, _ ) =
                    smallStringSeed seed_
            in
                ( directory_, seed_ )

        ( list_, _ ) =
            List.unzip (List.map funOverwrite list)

        joined =
            "/" ++ (String.join "/" list_)
    in
        ( joined, s )


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


model : Int -> Filesystem
model seedInt =
    fsRandom seedInt


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
            1

        -- Gen.Utils.intRange 10 50 seedInt
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
                Helper.addFileRecursively
                initialFilesystem
                list
    in
        model
