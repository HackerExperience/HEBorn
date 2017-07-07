module Apps.Hebamp.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages as HebampMsg
import Apps.Hebamp.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Hebamp.Menu.Models exposing (Menu(..))


menuView : Model -> Html HebampMsg.Msg
menuView model =
    menuViewCreator
        HebampMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute HebampMsg.Msg
menuFor context =
    menuForCreator HebampMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuDummy ->
            []
