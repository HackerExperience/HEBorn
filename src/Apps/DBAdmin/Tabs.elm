module Apps.DBAdmin.Tabs exposing (..)

import Apps.DBAdmin.Models exposing (..)
import Game.Account.Database.Models as Database
import Apps.DBAdmin.Tabs.Servers.Helpers as Servers exposing (..)


toggleExpand : String -> MainTab -> Model -> Model
toggleExpand itemId tab app =
    case tab of
        TabServers ->
            Servers.toggleExpand itemId app

        _ ->
            app


enterEditing : String -> MainTab -> Database.Model -> Model -> Model
enterEditing itemId tab database app =
    case tab of
        TabServers ->
            Servers.enterEditing itemId database app

        _ ->
            app


leaveEditing : String -> MainTab -> Model -> Model
leaveEditing itemId tab app =
    case tab of
        TabServers ->
            Servers.leaveEditing itemId app

        _ ->
            app


updateTextFilter : String -> MainTab -> Database.Model -> Model -> Model
updateTextFilter newFilter tab database app =
    case tab of
        TabServers ->
            Servers.updateTextFilter newFilter database app

        _ ->
            app
