module Core.Subscribers.Account exposing (dispatch)

import Core.Dispatch.Account exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Game.Account.Messages as Account
import Game.Account.Finances.Messages as Finances
import Game.Account.Database.Messages as Database
import Game.Inventory.Messages as Inventory


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        SetGateway a ->
            [ account <| Account.HandleSetGateway a ]

        SetEndpoint a ->
            [ account <| Account.HandleSetEndpoint a ]

        Finances a ->
            fromFinances a

        Database a ->
            fromDatabase a

        SetContext a ->
            [ account <| Account.HandleSetContext a ]

        NewGateway a ->
            [ account <| Account.HandleNewGateway a ]

        PasswordAcquired a ->
            [ database <| Database.HandlePasswordAcquired a
            , apps [ Apps.BrowserMsg <| Browser.HandlePasswordAcquired a ]
            ]

        LogoutAndCrash a ->
            [ account <| Account.HandleLogoutAndCrash a ]

        Logout ->
            [ account <| Account.HandleLogout ]

        Inventory dispatch ->
            fromInventory dispatch


fromInventory : Inventory -> Subscribers
fromInventory dispatch =
    case dispatch of
        UsedInventoryEntry a ->
            [ inventory <| Inventory.HandleComponentUsed a
            ]

        FreedInventoryEntry a ->
            [ inventory <| Inventory.HandleComponentFreed a
            ]


fromFinances : Finances -> Subscribers
fromFinances dispatch =
    case dispatch of
        BankAccountClosed a ->
            [ accountFinances <| Finances.HandleBankAccountClosed a ]

        BankAccountUpdated ( a, b ) ->
            [ accountFinances <| Finances.HandleBankAccountUpdated a b ]

        BankAccountLogin a b ->
            [ accountFinances <| Finances.HandleBankAccountLogin a b ]

        BankAccountTransfer a b c d e f g h ->
            [ accountFinances <| Finances.HandleBankAccountTransfer a b c d e f g h ]


fromDatabase : Database -> Subscribers
fromDatabase dispatch =
    case dispatch of
        DatabaseAccountRemoved a ->
            [ database <| Database.HandleDatabaseAccountRemoved a ]

        DatabaseAccountUpdated ( a, b ) ->
            [ database <| Database.HandleDatabaseAccountUpdated a b ]
