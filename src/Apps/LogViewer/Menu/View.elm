module Apps.LogViewer.Menu.View
    exposing
        ( menuView
        , menuNav
        , menuContent
        )

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)
import OS.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages as ExplorerMsg
import Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LogViewer.Menu.Models exposing (Menu(..))


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
        MenuNav ->
            [ [ ( ContextMenu.item "A", MenuClick DoA id )
              , ( ContextMenu.item "B", MenuClick DoB id )
              ]
            ]

        MenuContent ->
            [ [ ( ContextMenu.item "c", MenuClick DoB id )
              , ( ContextMenu.item "d", MenuClick DoA id )
              ]
            ]


menuNav : Html.Attribute ExplorerMsg.Msg
menuNav =
    menuFor menuNav


menuContent : Html.Attribute ExplorerMsg.Msg
menuContent =
    menuFor MenuContent
