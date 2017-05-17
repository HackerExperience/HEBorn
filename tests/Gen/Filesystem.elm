module Gen.Filesystem exposing (..)

import Gen.Utils exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Helper.Filesystem as Helper


fileID : Int -> FileID
fileID seedInt =
    fuzz1 seedInt fileIDSeed


fileIDSeed : StringSeed
fileIDSeed seed =
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
    fuzz1 seedInt folderSeed


folderSeed : Seed -> ( File, Seed )
folderSeed seed =
    let
        ( id, seed1 ) =
            fileIDSeed seed

        ( name, seed2 ) =
            nameSeed seed1

        ( path, seed3 ) =
            pathSeed seed2

        folder =
            folderArgs id name path
    in
        ( folder, seed3 )


folderArgs : FileID -> String -> String -> File
folderArgs id name path =
    Folder { id = id, name = name, path = path }


stdFile : Int -> File
stdFile seedInt =
    fuzz1 seedInt stdFileSeed


stdFileSeed : Seed -> ( File, Seed )
stdFileSeed seed =
    let
        ( id, seed1 ) =
            fileIDSeed seed

        ( name, seed2 ) =
            nameSeed seed1

        ( path, seed3 ) =
            pathSeed seed2

        ( extension, seed4 ) =
            extensionSeed seed3

        ( version, size ) =
            ( fileVersion, fileSize )

        stdFile =
            stdFileArgs
                id
                name
                path
                extension
                version
                size
                []
    in
        ( stdFile, seed4 )


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


file : Int -> File
file seedInt =
    fuzz1 seedInt fileSeed


fileSeed : Seed -> ( File, Seed )
fileSeed seed =
    let
        ( buildStdFile, seed_ ) =
            boolSeed (seed)
    in
        if buildStdFile then
            stdFileSeed seed_
        else
            folderSeed seed_


fileList : Int -> List File
fileList seedInt =
    fuzz1 seedInt fileListSeed


fileListSeed : Seed -> ( List File, Seed )
fileListSeed seed =
    let
        ( size, seed_ ) =
            intRangeSeed 1 100 seed

        list =
            List.range 1 size

        reducer =
            \_ ( filesystem, seed ) ->
                let
                    ( file, seed_ ) =
                        fileSeed seed
                in
                    ( file :: filesystem, seed_ )
    in
        List.foldl reducer ( [], seed_ ) list


model : Int -> Filesystem
model seedInt =
    fuzz1 seedInt modelSeed


modelSeed : Seed -> ( Filesystem, Seed )
modelSeed seed =
    fsRandomSeed seed


fsRandom : Int -> Filesystem
fsRandom seedInt =
    fuzz1 seedInt fsRandomSeed


fsRandomSeed : Seed -> ( Filesystem, Seed )
fsRandomSeed seed =
    let
        ( fileList, seed_ ) =
            fileListSeed seed

        filesystem =
            List.foldl Helper.addFileRecursively fsEmpty fileList
    in
        ( filesystem, seed_ )
