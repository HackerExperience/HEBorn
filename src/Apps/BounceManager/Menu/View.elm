module Apps.BounceManager.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.BounceManager.Models exposing (Model)
import Apps.BounceManager.Messages as BounceManagerMsg
import Apps.BounceManager.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.BounceManager.Menu.Models exposing (Menu(..))


menuView : Model -> Html BounceManagerMsg.Msg
menuView model =
    menuViewCreator
        BounceManagerMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute BounceManagerMsg.Msg
menuFor context =
    menuForCreator BounceManagerMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuDummy ->
            []
