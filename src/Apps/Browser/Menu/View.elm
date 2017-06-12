module Apps.Browser.Menu.View
    exposing
        ( menuView
        , menuNav
        , menuContent
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages as BrowserMsg
import Apps.Browser.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Browser.Menu.Models exposing (Menu(..))


menuView : Model -> Html BrowserMsg.Msg
menuView model =
    menuViewCreator
        BrowserMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute BrowserMsg.Msg
menuFor context =
    menuForCreator BrowserMsg.MenuMsg MenuMsg context


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


menuNav : Html.Attribute BrowserMsg.Msg
menuNav =
    menuFor MenuNav


menuContent : Html.Attribute BrowserMsg.Msg
menuContent =
    menuFor MenuContent
