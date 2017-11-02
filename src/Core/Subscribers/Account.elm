module Core.Subscribers.Account exposing (dispatch)

import Core.Dispatch.Account exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Apps.Messages as Apps
import Apps.Browser.Messages as Browser
import Game.Messages as Game
import Game.Account.Messages as Account
import Game.Account.Database.Messages as Database


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        SetGateway a ->
            [ account <| Account.HandleSetGateway a ]

        SetEndpoint a ->
            [ account <| Account.HandleSetEndpoint a ]

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
