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
import Apps.Explorer.Context.Models exposing (Context(..))
import Apps.Explorer.Context.View exposing (contextView, contextNav, contextContent)
import Apps.Explorer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "explorer"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style



-- VIEW WRAPPER


type alias Entries =
    List Entry


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
    { type_ : ArchiveType
    , size : FileSize
    }


type EntryType
    = Fantasy
    | Group Bool EntryGroup (List Entries)
    | Archive ArchiveProp


type alias Entry =
    { type_ : EntryType
    , name : String
    }


entryIcon : EntryType -> Classes
entryIcon type_ =
    case type_ of
        Fantasy ->
            GenericArchiveIcon

        Group expanded groupType ch ->
            (case groupType of
                Dir ->
                    CasedDirIcon

                Branch ->
                    CasedOpIcon
            )

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


renderSidebarEntry : Entry -> Html msg
renderSidebarEntry entry =
    case entry.type_ of
        Group expanded gr childs ->
            renderSidebarGroup expanded childs entry.name gr

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


renderSidebarGroup expanded childs name grType =
    div [] []


renderExplorerEntry : Entry -> Html msg
renderExplorerEntry entry =
    case entry.type_ of
        Group expanded gr childs ->
            renderExplorerGroup expanded childs entry.name gr

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
                            div [ class [ CntListContainer ] ]
                                [ (renderExplorerEntry { entry | type_ = { entry.type_ | type_ = Archive (Executable exeMime ver Nothing) }} )
                                , div [ class [ CntListChilds ] ]
                                    (renderActionList
                                        actions
                                    )
                                ]
                    )
            )


renderExplorerGroup expanded childs name grType =
    div [] []



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
            , contextView model id
            ]


viewExplorerColumn : Explorer -> GameModel -> Html Msg
viewExplorerColumn explorer game =
    div
        [ contextNav
        , class [ Nav ]
        ]
        [ div [ class [ NavTree ] ]
            [ div [ class [ NavEntry, EntryDir, EntryExpanded ] ]
                [ div
                    [ class [ EntryView ] ]
                    [ span [ class [ CasedDirIcon, NavIcon ] ] []
                    , span [] [ text "Pictures" ]
                    ]
                , div
                    [ class [ EntryChilds ] ]
                    [ div
                        [ class [ NavEntry, EntryArchive ] ]
                        [ span [ class [ GenericArchiveIcon, NavIcon ] ] []
                        , span [] [ text "Purple Lotus 1.jpg" ]
                        ]
                    , div
                        [ class [ NavEntry, EntryArchive ] ]
                        [ span [ class [ GenericArchiveIcon, NavIcon ] ] []
                        , span [] [ text "Blue Orchid.png" ]
                        ]
                    , div
                        [ class [ NavEntry, EntryDir ] ]
                        [ div
                            [ class [ EntryView ] ]
                            [ span [ class [ CasedDirIcon, NavIcon ] ] []
                            , span [] [ text "Other Flowers" ]
                            ]
                        , div
                            [ class [ EntryChilds ] ]
                            []
                        ]
                    ]
                ]
            , div [ class [ NavEntry, EntryDir, EntryExpanded ] ]
                [ div
                    [ class [ EntryView ] ]
                    [ span [ class [ CasedOpIcon, NavIcon ] ] []
                    , span [] [ text "Tree" ]
                    ]
                , div
                    [ class [ EntryChilds ] ]
                    [ div
                        [ class [ NavEntry, EntryDir ] ]
                        [ div
                            [ class [ EntryView ] ]
                            [ span [ class [ CasedOpIcon, NavIcon ] ] []
                            , span [] [ text "Branch" ]
                            ]
                        , div
                            [ class [ EntryChilds ] ]
                            []
                        ]
                    , div
                        [ class [ NavEntry, EntryDir ] ]
                        [ div
                            [ class [ EntryView ] ]
                            [ span [ class [ CasedOpIcon, NavIcon ] ] []
                            , span [] [ text "AnotherBranch" ]
                            ]
                        , div
                            [ class [ EntryChilds ] ]
                            []
                        ]
                    , div
                        [ class [ NavEntry, EntryArchive ] ]
                        [ text "A Leaf" ]
                    ]
                ]
            ]
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
        [ contextContent
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
            [ div [ class [ CntListEntry, EntryDir ] ]
                [ span [ class [ DirIcon ] ] []
                , span [] [ text "Downloads" ]
                ]
            , div [ class [ CntListEntry, EntryArchive ] ]
                [ span [ class [ VirusIcon ] ] []
                , span [] [ text "MyVirus.spam" ]
                , span [] [ text "2.3" ]
                , span [] [ text "230 MB" ]
                ]
            , div [ class [ CntListContainer ] ]
                [ div [ class [ CntListEntry, EntryArchive ] ]
                    [ span [ class [ FirewallIcon ] ] []
                    , span [] [ text "TheWall.fwl" ]
                    , span [] [ text "4.0" ]
                    , span [] [ text "230 MB" ]
                    ]
                , div [ class [ CntListChilds ] ]
                    [ div []
                        [ span [ class [ ActiveIcon ] ] []
                        , span [] [ text "Active" ]
                        , span [] [ text "4.5" ]
                        , span [] []
                        ]
                    , div []
                        [ span [ class [ PassiveIcon ] ] []
                        , span [] [ text "Passive" ]
                        , span [] [ text "3.5" ]
                        , span [] []
                        ]
                    ]
                ]
            ]
        ]
