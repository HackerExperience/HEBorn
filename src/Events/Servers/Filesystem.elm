module Events.Servers.Filesystem
    exposing
        ( Event(..)
        , Index
        , EntryHeader
        , Entry(..)
        , FileBox
        , FolderWithChildrenData
        , FolderBox
        , handler
        , decoder
        )

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
    = Newfile Entry


type alias Index =
    List Entry


type Entry
    = FileEntry FileBox
    | FolderEntry FolderBox


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


handler : String -> Handler Event
handler event json =
    case event of
        "new_file" ->
            onNewFile json

        _ ->
            Nothing


decoder : Decoder Entry
decoder =
    oneOf
        [ file |> map FileEntry
        , (lazy folder) |> map FolderEntry
        ]



-- internals


entry : () -> Decoder Entry
entry _ =
    decoder


onNewFile : Handler Event
onNewFile json =
    decodeValue decoder json
        |> Result.map Newfile
        |> notify


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
