module Apps.ConnManager.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages as ConnManagerMsg
import Apps.ConnManager.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.ConnManager.Menu.Models exposing (Menu(..))


menuView : Model -> Html ConnManagerMsg.Msg
menuView model =
    menuViewCreator
        ConnManagerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute ConnManagerMsg.Msg
menuFor context =
    menuForCreator ConnManagerMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuDummy ->
            []
