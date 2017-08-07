module Game.Servers.Requests.FileIndex exposing (..)

import Json.Decode
    exposing
        -- this request contains no payload, so no problems with importing this
        ( Decoder
        , Value
        , decodeValue
        , andThen
        , oneOf
        , map
        , maybe
        , lazy
        , list
        , string
        , int
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Utils.Json.Decode exposing (date)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Servers.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)


type Response
    = OkResponse Index
    | NoOp


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


request : ConfigSource a -> Cmd Msg
request =
    Requests.request ServerFileIndexTopic
        (FileIndexRequest >> Request)
        Nothing
        emptyPayload


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decoder
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            -- TODO: handle errors
            NoOp



-- internals


decoder : Value -> Result String Index
decoder json =
    decodeValue index json


index : Decoder Index
index =
    list entry


entry : Decoder Entry
entry =
    oneOf
        [ file |> map FileEntry
        , folder |> map FolderEntry
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


folder : Decoder FolderBox
folder =
    decode folderConstructor
        |> required "children" (list <| lazy (\_ -> entry))
        |> required "name" string
        |> required "id" string


folderConstructor : List Entry -> FileName -> FileID -> FolderBox
folderConstructor children name id =
    { id = id
    , name = name
    , children = children
    }
