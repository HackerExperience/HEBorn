module Apps.Browser.Menu.View
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
import Apps.Instances.Models exposing (InstanceID)
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages as BrowserMsg
import Apps.Browser.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Browser.Menu.Models exposing (Menu(..))


menuView : Model -> InstanceID -> Html BrowserMsg.Msg
menuView model id =
    menuViewCreator
        BrowserMsg.MenuMsg
        model
        model.menu
        MenuMsg
        (menu id)


menuFor : Menu -> Html.Attribute BrowserMsg.Msg
menuFor context =
    menuForCreator BrowserMsg.MenuMsg MenuMsg context


menu : InstanceID -> Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu id model context =
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


menuNav : Html.Attribute BrowserMsg.Msg
menuNav =
    menuFor MenuNav


menuContent : Html.Attribute BrowserMsg.Msg
menuContent =
    menuFor MenuContent
