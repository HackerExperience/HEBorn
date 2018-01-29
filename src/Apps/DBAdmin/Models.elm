module Apps.DBAdmin.Models exposing (..)

import Dict exposing (Dict)


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


type alias Model =
    { selected : MainTab
    , servers : Tab
    , serversEditing : Dict String EditingServers
    , bankAccs : Tab
    , bankAccsEditing : Dict String Never
    , wallets : Tab
    , walletsEditing : Dict String Never
    }


name : String
name =
    "Database Admin"


title : Model -> String
title model =
    let
        filter =
            (.filterText) <| getTab model

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


getTab : Model -> Tab
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
    { selected = TabServers
    , servers = initialTab
    , serversEditing = Dict.empty
    , bankAccs = initialTab
    , bankAccsEditing = Dict.empty
    , wallets = initialTab
    , walletsEditing = Dict.empty
    }


initialTab : Tab
initialTab =
    { filterText = ""
    , filterFlags = []
    , filterCache = []
    , sorting = DefaultSort
    , expanded = []
    }


isEntryExpanded : String -> Model -> Bool
isEntryExpanded itemId model =
    List.member itemId <| (.expanded) <| getTab model


isEntryEditing : String -> Model -> Bool
isEntryEditing itemId model =
    case model.selected of
        TabServers ->
            Dict.member itemId model.serversEditing

        TabBankAccs ->
            Dict.member itemId model.bankAccsEditing

        TabWallets ->
            Dict.member itemId model.walletsEditing


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabServers ->
            "Servers"

        TabBankAccs ->
            "Bank Accounts"

        TabWallets ->
            "BTC Wallets"
