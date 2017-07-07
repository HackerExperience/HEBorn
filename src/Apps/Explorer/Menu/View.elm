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
            [ [ ( ContextMenu.item "Enter", fileID |> GoPath |> MenuClick )
              , ( ContextMenu.item "Rename", fileID |> EnterRename |> MenuClick )
              , ( ContextMenu.item "Move", fileID |> Moving |> UpdateEditing |> MenuClick )
              , ( ContextMenu.item "Delete", fileID |> Delete |> MenuClick )
              ]
            ]

        MenuTreeDir fileID ->
            [ [ ( ContextMenu.item "Toogle expansion", MenuClick Dummy )
              , ( ContextMenu.item "Rename", fileID |> EnterRename |> MenuClick )
              , ( ContextMenu.item "Delete Link", MenuClick Dummy )
              ]
            ]

        MenuMainArchive fileID ->
            [ [ ( ContextMenu.item "Rename", fileID |> EnterRename |> MenuClick )
              , ( ContextMenu.item "Move", fileID |> Moving |> UpdateEditing |> MenuClick )
              , ( ContextMenu.item "Delete", fileID |> Delete |> MenuClick )
              ]
            ]

        MenuTreeArchive fileID ->
            [ [ ( ContextMenu.item "Rename", fileID |> EnterRename |> MenuClick )
              , ( ContextMenu.item "Delete", fileID |> Delete |> MenuClick )
              ]
            ]

        MenuExecutable fileID ->
            [ [ ( ContextMenu.item "Run", fileID |> Run |> MenuClick )
              , ( ContextMenu.item "Research", fileID |> Research |> MenuClick )
              , ( ContextMenu.item "Rename", fileID |> EnterRename |> MenuClick )
              , ( ContextMenu.item "Move", fileID |> Moving |> UpdateEditing |> MenuClick )
              , ( ContextMenu.item "Delete", fileID |> Delete |> MenuClick )
              ]
            ]

        MenuActiveAction fileID ->
            [ [ ( ContextMenu.item "Run", fileID |> Run |> MenuClick )
              ]
            ]

        MenuPassiveAction fileID ->
            [ [ ( ContextMenu.item "Start", fileID |> Start |> MenuClick )
              , ( ContextMenu.item "Stop", fileID |> Stop |> MenuClick )
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
