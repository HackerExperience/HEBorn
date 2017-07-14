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


type alias FileModuleName =
    String


type alias FileModuleVersion =
    Int


type alias FileModule =
    { name : FileModuleName
    , version : FileModuleVersion
    }


type alias FileModules =
    List FileModule


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
    , modules : List FileModule
    }


type FolderChildren
    = List FileID


type alias FolderData =
    { children : FolderChildren }


type alias FileBox =
    EntryHeader FileData


type alias FolderBox =
    EntryHeader FolderData


type PathNode
    = Leaf FileID
    | Node PathTree


type alias PathTree =
    Dict FileName PathNode


type alias Filesystem =
    { entries : Entries
    , root : PathTree
    }


rootSymbol : String
rootSymbol =
    "/"


pathSeparator : String
pathSeparator =
    "/"


extensionSeparator : String
extensionSeparator =
    "."
