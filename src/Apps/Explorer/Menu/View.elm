module Apps.Explorer.Menu.View
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
        MenuNav ->
            [ [ ( ContextMenu.item "A", MenuClick DoA )
              , ( ContextMenu.item "B", MenuClick DoB )
              ]
            ]

        MenuContent ->
            [ [ ( ContextMenu.item "c", MenuClick DoB )
              , ( ContextMenu.item "d", MenuClick DoA )
              ]
            ]


menuNav : Html.Attribute ExplorerMsg.Msg
menuNav =
    menuFor MenuNav


menuContent : Html.Attribute ExplorerMsg.Msg
menuContent =
    menuFor MenuContent
