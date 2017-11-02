module Apps.LogViewer.Menu.View
    exposing
        ( menuView
        , menuNormalEntry
        , menuEditingEntry
        , menuEncryptedEntry
        , menuHiddenEntry
        , menuFilter
        )

import Html exposing (Html)
import ContextMenu exposing (ContextMenu)
import OS.SessionManager.WindowManager.MenuHandler.View
    exposing
        ( menuForCreator
        , menuViewCreator
        )
import Game.Servers.Logs.Models as Logs
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
              , ( ContextMenu.item "Encrypt", MenuClick (EncryptEntry logID) )
              , ( ContextMenu.item "Hide", MenuClick (HideEntry logID) )
              , ( ContextMenu.item "Delete", MenuClick (DeleteEntry logID) )
              ]
            ]

        MenuEditingEntry logID ->
            [ [ ( ContextMenu.item "Apply", MenuClick (EdittingEntryApply logID) )
              , ( ContextMenu.item "Cancel", MenuClick (EdittingEntryCancel logID) )
              ]
            ]

        MenuEncryptedEntry logID ->
            [ [ ( ContextMenu.item "Decrypt", MenuClick (DecryptEntry logID) )
              , ( ContextMenu.item "Hide", MenuClick (HideEntry logID) )
              , ( ContextMenu.item "Delete", MenuClick (DeleteEntry logID) )
              ]
            ]

        MenuHiddenEntry logID ->
            []

        MenuFilter ->
            -- TODO: Filter by flags
            []


menuNormalEntry : Logs.ID -> Html.Attribute LogViewer.Msg
menuNormalEntry logID =
    menuFor (MenuNormalEntry logID)


menuEditingEntry : Logs.ID -> Html.Attribute LogViewer.Msg
menuEditingEntry logID =
    menuFor (MenuEditingEntry logID)


menuEncryptedEntry : Logs.ID -> Html.Attribute LogViewer.Msg
menuEncryptedEntry logID =
    menuFor (MenuEncryptedEntry logID)


menuHiddenEntry : Logs.ID -> Html.Attribute LogViewer.Msg
menuHiddenEntry logID =
    menuFor (MenuHiddenEntry logID)


menuFilter : Html.Attribute LogViewer.Msg
menuFilter =
    menuFor MenuFilter
