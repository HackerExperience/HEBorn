module Apps.Template.Menu.View exposing (menuView, menuForDummy)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.Template.Models exposing (Model)
import Apps.Template.Messages as Parent
import Apps.Template.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.Template.Menu.Models exposing (Menu(..))


menuView : Model -> Html Parent.Msg
menuView model =
    menuViewCreator
        Parent.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute Parent.Msg
menuFor context =
    menuForCreator Parent.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuDummy ->
            []


menuForDummy : Html.Attribute Parent.Msg
menuForDummy =
    (menuFor MenuDummy)
