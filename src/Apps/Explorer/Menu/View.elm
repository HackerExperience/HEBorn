module Apps.Explorer.Menu.View
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

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import Game.Servers.Filesystem.Shared exposing (FileID)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Explorer.Models exposing (Model, EditingStatus(..))
import Apps.Explorer.Messages as ExplorerMsg
import Apps.Explorer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Explorer.Menu.Models exposing (Menu(..))


menuView : Model -> Html ExplorerMsg.Msg
menuView model =
    menuViewCreator
        ExplorerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute ExplorerMsg.Msg
menuFor context =
    menuForCreator ExplorerMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuMainDir fileID ->
            [ [ ( ContextMenu.item "Enter"
                , MenuClick <| GoPath fileID
                )
              , ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuTreeDir fileID ->
            [ [ ( ContextMenu.item "Toogle expansion"
                , MenuClick Dummy
                )
              , ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Delete Link"
                , MenuClick Dummy
                )
              ]
            ]

        MenuMainArchive fileID ->
            [ [ ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuTreeArchive fileID ->
            [ [ ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuExecutable fileID ->
            [ [ ( ContextMenu.item "Run"
                , MenuClick <| Run fileID
                )
              , ( ContextMenu.item "Research"
                , MenuClick <| Research fileID
                )
              , ( ContextMenu.item "Rename"
                , MenuClick <| EnterRename fileID
                )
              , ( ContextMenu.item "Move"
                , MenuClick <| UpdateEditing <| Moving fileID
                )
              , ( ContextMenu.item "Delete"
                , MenuClick <| Delete fileID
                )
              ]
            ]

        MenuActiveAction fileID ->
            [ [ ( ContextMenu.item "Run"
                , MenuClick <| Run fileID
                )
              ]
            ]

        MenuPassiveAction fileID ->
            [ [ ( ContextMenu.item "Start"
                , MenuClick <| Start fileID
                )
              , ( ContextMenu.item "Stop"
                , MenuClick <| Stop fileID
                )
              ]
            ]


menuMainDir : FileID -> Html.Attribute ExplorerMsg.Msg
menuMainDir fileID =
    menuFor (MenuMainDir fileID)


menuTreeDir : FileID -> Html.Attribute ExplorerMsg.Msg
menuTreeDir fileID =
    menuFor (MenuTreeDir fileID)


menuMainArchive : FileID -> Html.Attribute ExplorerMsg.Msg
menuMainArchive fileID =
    menuFor (MenuMainArchive fileID)


menuTreeArchive : FileID -> Html.Attribute ExplorerMsg.Msg
menuTreeArchive fileID =
    menuFor (MenuTreeArchive fileID)


menuExecutable : FileID -> Html.Attribute ExplorerMsg.Msg
menuExecutable fileID =
    menuFor (MenuExecutable fileID)


menuPassiveAction : FileID -> Html.Attribute ExplorerMsg.Msg
menuPassiveAction fileID =
    menuFor (MenuPassiveAction fileID)


menuActiveAction : FileID -> Html.Attribute ExplorerMsg.Msg
menuActiveAction fileID =
    menuFor (MenuActiveAction fileID)
