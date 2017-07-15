module Game.Servers.Filesystem.Shared exposing (..)

import Dict exposing (Dict)


type alias FileID =
    String


type alias FileName =
    String


type alias FileExtension =
    String


type alias Location =
    List FileName


type alias FilePath =
    ( Location, FileName )


type alias FileSize =
    Maybe Int


type alias FileVersion =
    Maybe Int


type alias ModuleName =
    String


type alias ModuleVersion =
    Int


type alias Module =
    { name : ModuleName
    , version : ModuleVersion
    }


type alias Modules =
    List Module


type ParentReference
    = RootRef
    | NodeRef FileID


type alias Entries =
    Dict FileID Entry


type Entry
    = FileEntry FileBox
    | FolderEntry FolderBox


type alias EntryHeader ext =
    { ext
        | id : FileID
        , name : FileName
        , parent : ParentReference
    }


type alias FileData =
    { size : FileSize
    , version : FileVersion
    , modules : List Module
    , extension : String
    }


type alias FolderData =
    {}


type alias FileBox =
    EntryHeader FileData


type alias FolderBox =
    EntryHeader FolderData


type PathNode
    = Leaf FileID
    | Node FileID PathTree


type alias PathTree =
    Dict FileName PathNode


type alias Filesystem =
    { entries : Entries
    , rootTree : PathTree
    }


type IOErr
    = MissingParent
    | ParentIsFile
    | NotEmptyDir


type alias IOResult a =
    Result IOErr a


rootSymbol : String
rootSymbol =
    "/"


pathSeparator : String
pathSeparator =
    "/"


extensionSeparator : String
extensionSeparator =
    "."
