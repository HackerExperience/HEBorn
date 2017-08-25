module Events.Servers.Filesystem exposing (Event(..), handler, decoder, apply)

import Utils.Events exposing (Handler, notify)
import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , oneOf
        , map
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


type Event
    = Changed Index


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing


apply : Filesystem -> Index -> Filesystem
apply model values =
    List.foldl (convEntry RootRef) model values


decoder : Decoder Index
decoder =
    list <| lazy entry



-- internals


onChanged : Handler Event
onChanged json =
    decodeValue decoder json
        |> Result.map Changed
        |> notify


type alias Index =
    List Entry


type alias EntryHeader ext =
    { ext
        | id : FileID
        , name : FileName
    }


type Entry
    = FileEntry FileBox
    | FolderEntry FolderBox


type alias FileBox =
    EntryHeader FileData


type alias FolderWithChildrenData =
    { children : Index }


type alias FolderBox =
    EntryHeader FolderWithChildrenData


entry : () -> Decoder Entry
entry () =
    oneOf
        [ file |> map FileEntry
        , (lazy folder) |> map FolderEntry
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


fileConstructor : String -> FileSize -> FileVersion -> List Module -> FileName -> FileID -> FileBox
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


convEntry : ParentReference -> Entry -> Filesystem.Filesystem -> Filesystem.Filesystem
convEntry parentRef src filesystem =
    -- TODO: rewrite to be more readable
    case src of
        FileEntry data ->
            addEntry
                (Filesystem.FileEntry
                    { id = data.id
                    , name = data.name
                    , parent = parentRef
                    , extension = data.extension
                    , version = data.version
                    , size = data.size
                    , modules = data.modules
                    }
                )
                filesystem

        FolderEntry data ->
            let
                meAdded =
                    addEntry
                        (Filesystem.FolderEntry
                            { id = data.id
                            , name = data.name
                            , parent = parentRef
                            }
                        )
                        filesystem

                parentRef =
                    Filesystem.NodeRef data.id
            in
                List.foldl
                    (convEntry parentRef)
                    meAdded
                    data.children
