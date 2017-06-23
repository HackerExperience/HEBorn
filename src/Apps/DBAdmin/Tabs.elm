module Apps.DBAdmin.Tabs exposing (..)

import Apps.DBAdmin.Models exposing (..)
import Game.Account.Database.Models exposing (Database)
import Apps.DBAdmin.Tabs.Servers.Helpers as Servers exposing (..)


toComparable : MainTab -> Int
toComparable tab =
    case tab of
        TabServers ->
            0

        TabBankAccs ->
            1

        TabWallets ->
            2


fromComparable : Int -> MainTab
fromComparable v =
    case v of
        1 ->
            TabBankAccs

        2 ->
            TabWallets

        _ ->
            TabServers


toggleExpand : String -> MainTab -> DBAdmin -> DBAdmin
toggleExpand itemId tab app =
    case tab of
        TabServers ->
            Servers.toggleExpand itemId app

        _ ->
            app


enterEditing : String -> MainTab -> Database -> DBAdmin -> DBAdmin
enterEditing itemId tab database app =
    case tab of
        TabServers ->
            Servers.enterEditing itemId database app

        _ ->
            app


leaveEditing : String -> MainTab -> DBAdmin -> DBAdmin
leaveEditing itemId tab app =
    case tab of
        TabServers ->
            Servers.leaveEditing itemId app

        _ ->
            app


updateTextFilter : String -> MainTab -> Database -> DBAdmin -> DBAdmin
updateTextFilter newFilter tab database app =
    case tab of
        TabServers ->
            Servers.updateTextFilter newFilter database app

        _ ->
            app
