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


type alias ModuleData =
    { version : Maybe Int }


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
    { extension : String
    , size : FileSize
    , version : FileVersion
    , mime : Mime
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


type Mime
    = Cracker CrackerModules
    | Firewall FirewallModules
    | Text
    | Exploit ExploitModules
    | Hasher HasherModules
    | LogForger LogForgerModules
    | LogRecover LogRecoverModules
    | Encryptor EncryptorModules
    | Decryptor DecryptorModules
    | Anymap AnymapModules
    | CryptoKey


type alias CrackerModules =
    { bruteForce : ModuleData
    , overFlow : ModuleData
    }


type alias FirewallModules =
    { active : ModuleData
    , passive : ModuleData
    }


type alias ExploitModules =
    { ftp : ModuleData
    , ssh : ModuleData
    }


type alias HasherModules =
    { password : ModuleData
    }


type alias LogForgerModules =
    { create : ModuleData
    , edit : ModuleData
    }


type alias LogRecoverModules =
    { recover : ModuleData
    }


type alias EncryptorModules =
    { file : ModuleData
    , log : ModuleData
    , connection : ModuleData
    , process : ModuleData
    }


type alias DecryptorModules =
    { file : ModuleData
    , log : ModuleData
    , connection : ModuleData
    , process : ModuleData
    }


type alias AnymapModules =
    { geo : ModuleData
    , net : ModuleData
    }


type alias Foreigners =
    List Foreigner


type Foreigner
    = ForeignFile ForeignFileBox
    | ForeignFolder ForeignFolderBox


type alias ForeignFileBox =
    ForeignerHeader FileData


type alias ForeignFolderBox =
    ForeignerHeader FolderWithChildrenData


type alias FolderWithChildrenData =
    { children : Foreigners }


type alias ForeignerHeader ext =
    { ext
        | id : FileID
        , name : FileName
    }
