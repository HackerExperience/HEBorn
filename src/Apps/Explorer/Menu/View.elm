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
import Game.Servers.Filesystem.Models exposing (FileID)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Explorer.Models exposing (Model)
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
            [ [ ( ContextMenu.item "Enter", MenuClick Dummy )
              , ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Move", MenuClick Dummy )
              , ( ContextMenu.item "Delete", MenuClick (DeleteFile fileID) )
              ]
            ]

        MenuTreeDir fileID ->
            [ [ ( ContextMenu.item "Toogle expansion", MenuClick Dummy )
              , ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Delete Link", MenuClick Dummy )
              ]
            ]

        MenuMainArchive fileID ->
            [ [ ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Move", MenuClick Dummy )
              , ( ContextMenu.item "Delete", MenuClick (DeleteFile fileID) )
              ]
            ]

        MenuTreeArchive fileID ->
            [ [ ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Delete", MenuClick (DeleteFile fileID) )
              ]
            ]

        MenuExecutable fileID ->
            [ [ ( ContextMenu.item "Run", MenuClick Dummy )
              , ( ContextMenu.item "Research", MenuClick Dummy )
              , ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Move", MenuClick Dummy )
              , ( ContextMenu.item "Delete", MenuClick (DeleteFile fileID) )
              ]
            ]

        MenuActiveAction fileID ->
            [ [ ( ContextMenu.item "Run", MenuClick Dummy )
              ]
            ]

        MenuPassiveAction fileID ->
            [ [ ( ContextMenu.item "Start", MenuClick Dummy )
              , ( ContextMenu.item "Stop", MenuClick Dummy )
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
