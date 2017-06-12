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
        MenuMainDir ->
            [ [ ( ContextMenu.item "Enter", MenuClick Dummy )
              ]
            ]

        MenuTreeDir ->
            [ [ ( ContextMenu.item "Toogle expansion", MenuClick Dummy )
              ]
            ]

        MenuMainArchive ->
            [ [ ( ContextMenu.item "Delete", MenuClick Dummy )
              , ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Move", MenuClick Dummy )
              ]
            ]

        MenuTreeArchive ->
            [ [ ( ContextMenu.item "Delete", MenuClick Dummy )
              , ( ContextMenu.item "Rename", MenuClick Dummy )
              ]
            ]

        MenuExecutable ->
            [ [ ( ContextMenu.item "Run", MenuClick Dummy )
              , ( ContextMenu.item "Research", MenuClick Dummy )
              , ( ContextMenu.item "Delete", MenuClick Dummy )
              , ( ContextMenu.item "Rename", MenuClick Dummy )
              , ( ContextMenu.item "Move", MenuClick Dummy )
              ]
            ]

        MenuActiveAction ->
            [ [ ( ContextMenu.item "Run", MenuClick Dummy )
              ]
            ]

        MenuPassiveAction ->
            [ [ ( ContextMenu.item "Start", MenuClick Dummy )
              , ( ContextMenu.item "Stop", MenuClick Dummy )
              ]
            ]


menuMainDir : Html.Attribute ExplorerMsg.Msg
menuMainDir =
    menuFor MenuMainDir


menuTreeDir : Html.Attribute ExplorerMsg.Msg
menuTreeDir =
    menuFor MenuTreeDir


menuMainArchive : Html.Attribute ExplorerMsg.Msg
menuMainArchive =
    menuFor MenuMainArchive


menuTreeArchive : Html.Attribute ExplorerMsg.Msg
menuTreeArchive =
    menuFor MenuTreeArchive


menuExecutable : Html.Attribute ExplorerMsg.Msg
menuExecutable =
    menuFor MenuExecutable


menuPassiveAction : Html.Attribute ExplorerMsg.Msg
menuPassiveAction =
    menuFor MenuPassiveAction


menuActiveAction : Html.Attribute ExplorerMsg.Msg
menuActiveAction =
    menuFor MenuActiveAction
