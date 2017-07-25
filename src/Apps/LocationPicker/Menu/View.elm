module Apps.LocationPicker.Menu.View exposing (menuView, menuForDummy)

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Apps.LocationPicker.Models exposing (Model)
import Apps.LocationPicker.Messages as Parent
import Apps.LocationPicker.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LocationPicker.Menu.Models exposing (Menu(..))


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
