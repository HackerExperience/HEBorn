module Apps.DBAdmin.Models exposing (..)

import Dict exposing (Dict)
import Apps.DBAdmin.Menu.Models as Menu


type MainTab
    = TabServers
    | TabBankAccs
    | TabWallets


type Sorting
    = DefaultSort


type EditingServers
    = EditingTexts ( String, String )
    | SelectingVirus (Maybe String)


type alias Tab =
    { filterText : String
    , filterFlags : List Never
    , filterCache : List String
    , sorting : Sorting
    , expanded : List String
    }


type alias DBAdmin =
    { selected : MainTab
    , servers : Tab
    , serversEditing : Dict String EditingServers
    , bankAccs : Tab
    , bankAccsEditing : Dict String Never
    , wallets : Tab
    , walletsEditing : Dict String Never
    }


type alias Model =
    { app : DBAdmin
    , menu : Menu.Model
    }


name : String
name =
    "Database Admin"


title : Model -> String
title ({ app } as model) =
    let
        filter =
            (getTab app).filterText

        posfix =
            Nothing

        --TODO
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "udb"


getTab : DBAdmin -> Tab
getTab app =
    case app.selected of
        TabServers ->
            app.servers

        TabBankAccs ->
            app.bankAccs

        TabWallets ->
            app.wallets


initialModel : Model
initialModel =
    { app = initialDBAdmin
    , menu = Menu.initialMenu
    }


initialTab : Tab
initialTab =
    { filterText = ""
    , filterFlags = []
    , filterCache = []
    , sorting = DefaultSort
    , expanded = []
    }


initialDBAdmin : DBAdmin
initialDBAdmin =
    { selected = TabServers
    , servers = initialTab
    , serversEditing = Dict.empty
    , bankAccs = initialTab
    , bankAccsEditing = Dict.empty
    , wallets = initialTab
    , walletsEditing = Dict.empty
    }


isEntryExpanded : DBAdmin -> String -> Bool
isEntryExpanded app itemId =
    List.member itemId (getTab app).expanded


isEntryEditing : DBAdmin -> String -> Bool
isEntryEditing app itemId =
    case app.selected of
        TabServers ->
            Dict.member itemId app.serversEditing

        TabBankAccs ->
            Dict.member itemId app.bankAccsEditing

        TabWallets ->
            Dict.member itemId app.walletsEditing


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabServers ->
            "Servers"

        TabBankAccs ->
            "Bank Accounts"

        TabWallets ->
            "BTC Wallets"
