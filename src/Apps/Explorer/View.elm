module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import UI.Widgets exposing (progressBar)
import UI.ToString exposing (bytesToString, secondsToTimeNotation)
import Css exposing (pct, width, asPairs)
import Game.Models exposing (GameModel)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (Model, Explorer, FilePath)
import Apps.Explorer.Menu.View
    exposing
        ( menuView
        , menuMainDir
        , menuTreeDir
        , menuMainArchive
        , menuTreeArchive
        , menuExecutable
        , menuActiveAction
        , menuPassiveAction
        )
import Apps.Explorer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "explorer"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style



-- VIEW WRAPPER


type alias FileSize =
    Float


type ActionTarget
    = Active
    | Passive


type alias Action =
    { target : ActionTarget
    , ver : ExeVer
    }


type alias ExeVer =
    Float


type ExeMime
    = Firewall
    | Virus


type EntryGroup
    = Dir
    | Branch


type ActionVer
    = EqualsExe
    | Unavailable
    | Just Float


type ArchiveType
    = Generic
    | Executable ExeMime ExeVer ActionVer ActionVer


type alias ArchiveProp =
    { size : FileSize
    , type_ : ArchiveType
    }


type EntryType
    = Fantasy
    | Group EntryGroup (List Entry)
    | Archive ArchiveProp


type alias Entry =
    { name : String
    , type_ : EntryType
    }


groupIcon : EntryGroup -> Classes
groupIcon type_ =
    case type_ of
        Dir ->
            CasedDirIcon

        Branch ->
            CasedOpIcon


entryIcon : EntryType -> Classes
entryIcon type_ =
    case type_ of
        Fantasy ->
            GenericArchiveIcon

        Group groupType ch ->
            groupIcon groupType

        Archive prop ->
            (case prop.type_ of
                Generic ->
                    GenericArchiveIcon

                Executable exeMime ver _ _ ->
                    (case exeMime of
                        Virus ->
                            VirusIcon

                        Firewall ->
                            FirewallIcon
                    )
            )


actionIcon : ActionTarget -> Classes
actionIcon actType =
    case actType of
        Active ->
            ActiveIcon

        Passive ->
            PassiveIcon


actionName : ActionTarget -> Html Msg
actionName actType =
    text
        (case actType of
            Active ->
                "Active"

            Passive ->
                "Passive"
        )


actionMenu : ActionTarget -> Attribute Msg
actionMenu actType =
    case actType of
        Active ->
            menuActiveAction

        Passive ->
            menuPassiveAction


verToText : ExeVer -> Html Msg
verToText ver =
    text (toString ver)


sizeToText : FileSize -> Html Msg
sizeToText size =
    text (bytesToString size)


renderAction : Action -> Html Msg
renderAction act =
    div [ actionMenu act.target ]
        [ span [ class [ actionIcon act.target ] ] []
        , span [] [ actionName act.target ]
        , span [] [ verToText act.ver ]
        , span [] []
        ]


renderActionList : List Action -> List (Html Msg)
renderActionList acts =
    List.map (\o -> renderAction o) acts


renderTreeEntry : Entry -> Html Msg
renderTreeEntry entry =
    case entry.type_ of
        Group gr childs ->
            renderTreeGroup childs entry.name gr

        Fantasy ->
            div
                [ class [ NavEntry, EntryArchive ] ]
                [ span [] [ text entry.name ] ]

        Archive prop ->
            div
                [ class [ NavEntry, EntryArchive ], menuTreeArchive ]
                [ span [ class [ NavIcon, entryIcon entry.type_ ] ] []
                , span [] [ text entry.name ]
                ]


renderTreeEntryList : List Entry -> List (Html Msg)
renderTreeEntryList list =
    List.map (\o -> renderTreeEntry o) list


renderTreeGroup : List Entry -> String -> EntryGroup -> Html Msg
renderTreeGroup childs name grType =
    div
        [ class
            ([ NavEntry, EntryDir ]
                ++ if ((List.length childs) > 0) then
                    [ EntryExpanded ]
                   else
                    []
            )
        ]
        [ div
            [ class [ EntryView ], menuTreeDir ]
            [ span [ class [ (groupIcon grType), NavIcon ] ] []
            , span [] [ text name ]
            ]
        , div
            [ class [ EntryChilds ] ]
            (renderTreeEntryList childs)
        ]


renderDetailedEntry : Entry -> Html Msg
renderDetailedEntry entry =
    case entry.type_ of
        Group gr childs ->
            div [ class [ CntListEntry, EntryDir ], menuMainDir ]
                [ span [ class [ DirIcon ] ] []
                , span [] [ text entry.name ]
                ]

        Fantasy ->
            div [ class [ CntListEntry, EntryArchive ] ]
                [ span [] [ text entry.name ] ]

        Archive prop ->
            (case prop.type_ of
                Generic ->
                    div [ class [ CntListEntry, EntryArchive ], menuMainArchive ]
                        [ span [ class [ entryIcon entry.type_ ] ] []
                        , span [] [ text entry.name ]
                        , span [] []
                        , span [] [ sizeToText prop.size ]
                        ]

                Executable exeMime ver active passive ->
                    (case ( active, passive ) of
                        ( Just activeVer, Just passiveVer ) ->
                            let
                                type_ =
                                    (Executable exeMime ver Unavailable Unavailable)

                                archive =
                                    Archive { prop | type_ = type_ }

                                entry_ =
                                    { entry | type_ = archive }

                                actions =
                                    [ Action Active activeVer
                                    , Action Passive passiveVer
                                    ]
                            in
                                div [ class [ CntListContainer ] ]
                                    [ (renderDetailedEntry entry_)
                                    , div [ class [ CntListChilds ] ]
                                        (renderActionList actions)
                                    ]

                        _ ->
                            div [ class [ CntListEntry, EntryArchive ], menuExecutable ]
                                [ span [ class [ entryIcon entry.type_ ] ] []
                                , span [] [ text entry.name ]
                                , span [] [ verToText ver ]
                                , span [] [ sizeToText prop.size ]
                                ]
                    )
            )


renderDetailedEntryList : List Entry -> List (Html Msg)
renderDetailedEntryList list =
    List.map (\o -> renderDetailedEntry o) list



-- END OF THAT


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    div [ class [ Window ] ]
        [ viewExplorerColumn app game
        , viewExplorerMain app game
        , menuView model
        ]


viewUsage : FileSize -> FileSize -> Html Msg
viewUsage min max =
    let
        usage =
            min / max

        minStr =
            bytesToString min

        maxStr =
            bytesToString max
    in
        div [ class [ NavData ] ]
            [ text "Data usage"
            , br [] []
            , text (toString (floor (usage * 100)) ++ "%")
            , br [] []
            , progressBar usage "" 12
            , br [] []
            , text (minStr ++ " / " ++ maxStr)
            ]


viewExplorerColumn : Explorer -> GameModel -> Html Msg
viewExplorerColumn explorer game =
    div
        [ class [ Nav ]
        ]
        [ div [ class [ NavTree ] ]
            (renderTreeEntryList dummyMain)
        , (viewUsage 256000000 1024000000)
        ]


stripPath : FilePath -> FilePath
stripPath path =
    let
        stripRight =
            (if (String.right 1 path == "/") then
                (String.dropRight 1 path)
             else
                path
            )
    in
        (if (String.left 1 stripRight == "/") then
            (String.dropLeft 1 stripRight)
         else
            stripRight
        )


viewLocBar : FilePath -> Html Msg
viewLocBar path =
    div
        [ class [ LocBar ] ]
        (List.map
            (\o ->
                span
                    [ class [ BreadcrumbItem ] ]
                    [ text o ]
            )
            (String.split "/" (stripPath path))
        )


viewExplorerMain : Explorer -> GameModel -> Html Msg
viewExplorerMain explorer game =
    div
        [ class
            [ Content ]
        ]
        [ div
            [ class [ ContentHeader ] ]
            [ viewLocBar explorer.path
            , div
                [ class [ ActBtns ] ]
                [ span
                    [ class [ GoUpBtn ] ]
                    []
                , span
                    [ class [ DocBtn, NewBtn ] ]
                    []
                , span
                    [ class [ DirBtn, NewBtn ] ]
                    []
                ]
            ]
        , div
            [ class [ ContentList ] ]
            (renderDetailedEntryList dummySidebar)
        ]



-- DUMMY VALUES


dummySidebar : List Entry
dummySidebar =
    [ { name = "Downloads"
      , type_ =
            Group
                Dir
                []
      }
    , { name = "MyVirus.spam"
      , type_ =
            Archive { size = 230000, type_ = Executable Virus 2.3 EqualsExe Unavailable }
      }
    , { name = "TheWall.fwl"
      , type_ =
            Archive
                { size = 240000
                , type_ =
                    Executable Firewall
                        4.0
                        (Just 4.5)
                        (Just 3.5)
                }
      }
    ]


dummyMain : List Entry
dummyMain =
    [ { name = "Pictures"
      , type_ =
            Group
                Dir
                [ { name = "Purple Lotus 1.jpg"
                  , type_ =
                        Archive
                            { size = 0
                            , type_ = Generic
                            }
                  }
                , { name = "Blue Orchid.png"
                  , type_ =
                        Archive
                            { size = 0
                            , type_ = Generic
                            }
                  }
                , { name = "Other Flowers"
                  , type_ =
                        Group
                            Dir
                            []
                  }
                ]
      }
    , { name = "Tree"
      , type_ =
            Group
                Branch
                [ { name = "Branch"
                  , type_ =
                        Group
                            Branch
                            []
                  }
                , { name = "AnotherBranch"
                  , type_ =
                        Group
                            Branch
                            []
                  }
                , { name = "A Leaf"
                  , type_ = Fantasy
                  }
                ]
      }
    ]
