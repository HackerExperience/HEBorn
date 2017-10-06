module Apps.Explorer.Resources exposing (..)


type Classes
    = Window
    | Nav
    | Content
    | ContentHeader
    | ContentList
    | LocBar
    | ActBtns
    | DirBtn
    | DocBtn
    | NewBtn
    | GoUpBtn
    | BreadcrumbItem
    | CntListContainer
    | CntListEntry
    | CntListChilds
    | EntryDir
    | EntryArchive
    | EntryExpanded
    | VirusIcon
    | FirewallIcon
    | ActiveIcon
    | PassiveIcon
    | DirIcon
    | GenericArchiveIcon
    | CasedDirIcon
    | CasedOpIcon
    | NavEntry
    | NavTree
    | NavData
    | NavIcon
    | EntryView
    | EntryChilds


prefix : String
prefix =
    "explorer"


idAttrKey : String
idAttrKey =
    "id"
