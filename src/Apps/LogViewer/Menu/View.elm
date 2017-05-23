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
import Apps.Instances.Models exposing (InstanceID)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages as LogVwMsg
import Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LogViewer.Menu.Models exposing (Menu(..))


menuView : Model -> InstanceID -> Html LogVwMsg.Msg
menuView model id =
    menuViewCreator
        LogVwMsg.MenuMsg
        model
        model.menu
        MenuMsg
        (menu id)


menuFor : Menu -> Html.Attribute LogVwMsg.Msg
menuFor context =
    menuForCreator LogVwMsg.MenuMsg MenuMsg context


menu : InstanceID -> Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu id model context =
    case context of
        MenuNormalEntry ->
            [ [ ( ContextMenu.item "Edit", MenuClick NormalEntryEdit id )
              ]
            ]


menuNormalEntry : Html.Attribute LogVwMsg.Msg
menuNormalEntry =
    menuFor MenuNormalEntry
