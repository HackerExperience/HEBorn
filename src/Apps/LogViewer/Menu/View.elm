module Apps.LogViewer.Menu.View
    exposing
        ( menuView
        , menuNormalEntry
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
import Apps.LogViewer.Messages as LogVwMsg
import Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LogViewer.Menu.Models exposing (Menu(..))


menuView : Model -> Html LogVwMsg.Msg
menuView model =
    menuViewCreator
        LogVwMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute LogVwMsg.Msg
menuFor context =
    menuForCreator LogVwMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuNormalEntry ->
            [ [ ( ContextMenu.item "Edit", MenuClick NormalEntryEdit id )
              ]
            ]


menuNormalEntry : Html.Attribute LogVwMsg.Msg
menuNormalEntry =
    menuFor MenuNormalEntry
