module Apps.Finance.Menu.View exposing (menuView)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Finance.Models exposing (Model)
import Apps.Finance.Messages as FinanceMsg
import Apps.Finance.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Finance.Menu.Models exposing (Menu(..))


menuView : Model -> Html FinanceMsg.Msg
menuView model =
    menuViewCreator
        FinanceMsg.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute FinanceMsg.Msg
menuFor context =
    menuForCreator FinanceMsg.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuDummy ->
            []
