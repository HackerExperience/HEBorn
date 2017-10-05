module Decoders.Filesystem exposing (..)

import Json.Decode
    exposing
        ( Decoder
        , oneOf
        , map
        , succeed
        , maybe
        , lazy
        , list
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)
import Game.Servers.Filesystem.Models exposing (..)


type alias Index =
    List IndexEntry


type IndexEntry
    = LeafEntry FileBox
    | NodeEntry FolderBox


type alias FileBox =
    EntryHeader FileData


type alias FolderBox =
    EntryHeader FolderWithChildrenData


type alias EntryHeader ext =
    { ext
        | id : FileID
        , name : FileName
    }


type alias FolderWithChildrenData =
    { children : Index }


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


index : Decoder Index
index =
    oneOf
        -- [α ONLY] TEMPORARY FALLBACK
        [ list (entry ())
        , succeed []
        ]


apply : Index -> Filesystem -> Filesystem
apply =
    let
        convEntry parentRef src filesystem =
            case src of
                LeafEntry data ->
                    let
                        entry =
                            FileEntry
                                { id = data.id
                                , name = data.name
                                , parent = parentRef
                                , extension = data.extension
                                , version = data.version
                                , size = data.size
                                , modules = data.modules
                                }
                    in
                        addEntry entry filesystem

                NodeEntry data ->
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


entry : () -> Decoder IndexEntry
entry () =
    oneOf
        [ file |> map LeafEntry
        , (lazy folder) |> map NodeEntry
        ]


file : Decoder FileBox
file =
    decode fileConstructor
        |> required "extension" string
        |> optional "size" (maybe int) Nothing
        |> optional "version" (maybe int) Nothing
        |> optional "modules" (list module_) []
        |> required "name" string
        |> required "id" string


module_ : Decoder Module
module_ =
    decode Module
        |> required "name" string
        |> required "version" int


fileConstructor :
    String
    -> FileSize
    -> FileVersion
    -> List Module
    -> FileName
    -> FileID
    -> FileBox
fileConstructor ext sz ver mods name id =
    { id = id
    , name = name
    , extension = ext
    , size = sz
    , version = ver
    , modules = mods
    }


folder : () -> Decoder FolderBox
folder () =
    decode folderConstructor
        |> required "children" (list <| lazy entry)
        |> required "name" string
        |> required "id" string


folderConstructor : Index -> FileName -> FileID -> FolderBox
folderConstructor children name id =
    { id = id
    , name = name
    , children = children
    }
