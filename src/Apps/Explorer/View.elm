module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models exposing (FilePath)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (Model, Explorer, getState)
import Apps.Explorer.Menu.Models exposing (Menu(..))
import Apps.Explorer.Menu.View exposing (menuView, menuNav, menuContent)
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


type ArchiveType
    = Generic
    | Executable ExeMime ExeVer (Maybe (List Action))


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

                Executable exeMime ver acts ->
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


sizeToText : FileSize -> Html msg
sizeToText size =
    text ((toString size) ++ " MB")


verToText : ExeVer -> Html msg
verToText ver =
    text (toString ver)


renderAction : Action -> Html Msg
renderAction act =
    div []
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
            renderSidebarGroup childs entry.name gr

        Fantasy ->
            div
                [ class [ NavEntry, EntryArchive ] ]
                [ span [] [ text entry.name ] ]

        Archive prop ->
            div
                [ class [ NavEntry, EntryArchive ] ]
                [ span [ class [ NavIcon, entryIcon entry.type_ ] ] []
                , span [] [ text entry.name ]
                ]


renderTreeEntryList : List Entry -> List (Html Msg)
renderTreeEntryList list =
    List.map (\o -> renderTreeEntry o) list


renderSidebarGroup childs name grType =
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
            [ class [ EntryView ] ]
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
            div [ class [ CntListEntry, EntryDir ] ]
                [ span [ class [ DirIcon ] ] []
                , span [] [ text entry.name ]
                ]

        Fantasy ->
            div [ class [ CntListEntry, EntryArchive ] ]
                [ span [] [ text entry.name ] ]

        Archive prop ->
            (case prop.type_ of
                Generic ->
                    div [ class [ CntListEntry, EntryArchive ] ]
                        [ span [ class [ entryIcon entry.type_ ] ] []
                        , span [] [ text entry.name ]
                        , span [] []
                        , span [] [ sizeToText prop.size ]
                        ]

                Executable exeMime ver actsCont ->
                    (case actsCont of
                        Nothing ->
                            div [ class [ CntListEntry, EntryArchive ] ]
                                [ span [ class [ entryIcon entry.type_ ] ] []
                                , span [] [ text entry.name ]
                                , span [] [ verToText ver ]
                                , span [] [ sizeToText prop.size ]
                                ]

                        Just actions ->
                            let
                                type_ =
                                    (Executable exeMime ver Nothing)

                                archive =
                                    Archive { prop | type_ = type_ }

                                entry_ =
                                    { entry | type_ = archive }
                            in
                                div [ class [ CntListContainer ] ]
                                    [ (renderDetailedEntry entry_)
                                    , div [ class [ CntListChilds ] ]
                                        (renderActionList actions)
                                    ]
                    )
            )


renderDetailedEntryList : List Entry -> List (Html Msg)
renderDetailedEntryList list =
    List.map (\o -> renderDetailedEntry o) list



-- END OF THAT


view : Model -> InstanceID -> GameModel -> Html Msg
view model id game =
    let
        explorer =
            getState model id
    in
        div [ class [ Window ] ]
            [ viewExplorerColumn explorer game
            , viewExplorerMain explorer game
            , menuView model id
            ]


viewExplorerColumn : Explorer -> GameModel -> Html Msg
viewExplorerColumn explorer game =
    div
        [ menuNav
        , class [ Nav ]
        ]
        [ div [ class [ NavTree ] ]
            (renderTreeEntryList
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
                                        Dir
                                        []
                              }
                            , { name = "A Leaf"
                              , type_ = Fantasy
                              }
                            ]
                  }
                ]
            )
        , div [ class [ NavData ] ]
            [ text "Data usage"
            , br [] []
            , text "82%"
            , br [] []
            , div
                [ class [ ProgBar ] ]
                [ div
                    [ class [ [ ProgFill ] ]
                    , styles [ Css.width (pct 50) ]
                    ]
                    []
                ]
            , br [] []
            , text "289 MB / 1000 MB"
            ]
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
        [ menuContent
        , class
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
            (renderDetailedEntryList
                [ { name = "Downloads"
                  , type_ =
                        Group
                            Dir
                            []
                  }
                , { name = "MyVirus.spam"
                  , type_ =
                        Archive { size = 230, type_ = Executable Virus 2.3 Nothing }
                  }
                , { name = "TheWall.fwl"
                  , type_ =
                        Archive
                            { size = 230
                            , type_ =
                                Executable Firewall
                                    4.0
                                    (Just
                                        [ { target = Active, ver = 4.5 }
                                        , { target = Passive, ver = 3.5 }
                                        ]
                                    )
                            }
                  }
                ]
            )
        ]
