module Decoders.Filesystem exposing (..)

import Dict exposing (Dict)
import Json.Decode
    exposing
        ( Decoder
        , map
        , andThen
        , field
        , oneOf
        , succeed
        , fail
        , maybe
        , lazy
        , list
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Utils.Json.Decode exposing (commonError)


model : Maybe Filesystem.Filesystem -> Decoder Filesystem
model maybeFilesytem =
    let
        filesystem =
            case maybeFilesytem of
                Just filesystem ->
                    filesystem

                Nothing ->
                    initialModel
    in
        map (flip apply filesystem) index


index : Decoder Foreigners
index =
    oneOf
        -- [α ONLY] TEMPORARY FALLBACK
        [ list (entry ())
        , succeed []
        ]


apply : Foreigners -> Filesystem -> Filesystem
apply =
    let
        convEntry parentRef src filesystem =
            case src of
                ForeignFile data ->
                    let
                        entry =
                            FileEntry
                                { id = data.id
                                , name = data.name
                                , parent = parentRef
                                , extension = data.extension
                                , version = data.version
                                , size = data.size
                                , mime = data.mime
                                }
                    in
                        addEntry entry filesystem

                ForeignFolder data ->
                    let
                        entry =
                            FolderEntry
                                { id = data.id
                                , name = data.name
                                , parent = parentRef
                                }
                    in
                        List.foldl (convEntry <| NodeRef data.id)
                            (addEntry entry filesystem)
                            data.children
    in
        flip (List.foldl (convEntry RootRef))


entry : () -> Decoder Foreigner
entry () =
    oneOf
        [ file |> map ForeignFile
        , (lazy folder) |> map ForeignFolder
        ]


file : Decoder ForeignFileBox
file =
    decode fileConstructor
        |> required "id" string
        |> required "name" string
        |> required "extension" string
        |> optional "size" (maybe int) Nothing
        |> optional "version" (maybe int) Nothing
        |> custom mime


fileConstructor :
    FileID
    -> FileName
    -> String
    -> FileSize
    -> FileVersion
    -> Mime
    -> ForeignFileBox
fileConstructor id name ext sz ver mime =
    { id = id
    , name = name
    , extension = ext
    , size = sz
    , version = ver
    , mime = mime
    }


folder : () -> Decoder ForeignFolderBox
folder () =
    decode folderConstructor
        |> required "children" (list <| lazy entry)
        |> required "name" string
        |> required "id" string


folderConstructor : Foreigners -> FileName -> FileID -> ForeignFolderBox
folderConstructor children name id =
    { id = id
    , name = name
    , children = children
    }


mime : Decoder Mime
mime =
    field "type" string
        |> andThen decodeMime


decodeMime : String -> Decoder Mime
decodeMime type_ =
    case type_ of
        "cracker" ->
            modulesAssembler CrackerModules
                |> module_ "bruteforce"
                |> module_ "overflow"
                |> modulesResolve Cracker

        "firewall" ->
            modulesAssembler FirewallModules
                |> module_ "fwl_active"
                |> module_ "fwl_passive"
                |> modulesResolve Firewall

        _ ->
            fail <| commonError "file type" type_


type alias Modules =
    Dict String ModuleData


modules : Decoder Modules
modules =
    decode (,)
        |> required "name" string
        |> required "version" (map (Just >> ModuleData) int)
        |> list
        |> map Dict.fromList


modulesAssembler : (ModuleData -> b) -> Decoder ( Modules, ModuleData -> b )
modulesAssembler mimeType =
    field "modules" modules
        |> map (flip (,) mimeType)


module_ : String -> Decoder ( Modules, ModuleData -> b ) -> Decoder ( Modules, b )
module_ name =
    map <|
        \( src, fn ) ->
            case Dict.get name src of
                Just mod ->
                    ( src, fn mod )

                Nothing ->
                    ( src, fn <| ModuleData <| Nothing )


modulesResolve : (a -> Mime) -> Decoder ( Modules, a ) -> Decoder Mime
modulesResolve fn =
    map (Tuple.second >> fn)


moduleError : String -> Decoder Mime
moduleError value =
    fail <| commonError "file module" value
