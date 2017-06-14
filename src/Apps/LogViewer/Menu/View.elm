module Apps.LogViewer.Menu.View
    exposing
        ( menuView
        , menuNormalEntry
        , menuEditingEntry
        , menuFilter
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Game.Servers.Logs.Models exposing (..)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages as LogViewer
import Apps.LogViewer.Menu.Messages exposing (Msg(..), MenuAction(..))
import Apps.LogViewer.Menu.Models exposing (Menu(..))


menuView : Model -> Html LogViewer.Msg
menuView model =
    menuViewCreator
        LogViewer.MenuMsg
        model
        model.menu
        MenuMsg
        menu


menuFor : Menu -> Html.Attribute LogViewer.Msg
menuFor context =
    menuForCreator LogViewer.MenuMsg MenuMsg context


menu : Model -> Menu -> List (List ( ContextMenu.Item, Msg ))
menu model context =
    case context of
        MenuNormalEntry logID ->
            [ [ ( ContextMenu.item "Edit", MenuClick (NormalEntryEdit logID) )
              ]
            ]

        MenuEditingEntry logID ->
            [ [ ( ContextMenu.item "Apply", MenuClick (EdittingEntryApply logID) )
              , ( ContextMenu.item "Cancel", MenuClick (EdittingEntryCancel logID) )
              ]
            ]

        MenuFilter ->
            -- TODO: Filter by flags
            []


menuNormalEntry : ID -> Html.Attribute LogViewer.Msg
menuNormalEntry logID =
    menuFor (MenuNormalEntry logID)


menuEditingEntry : ID -> Html.Attribute LogViewer.Msg
menuEditingEntry logID =
    menuFor (MenuEditingEntry logID)


menuFilter : Html.Attribute LogViewer.Msg
menuFilter =
    menuFor MenuFilter
