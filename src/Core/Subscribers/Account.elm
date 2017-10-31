module Core.Subscribers.Account exposing (dispatch)

import Core.Dispatch.Account exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Account.Messages as Account


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        SetGateway a ->
            [ account <| Account.HandleSetGateway a ]

        SetEndpoint a ->
            [ account <| Account.HandleSetEndpoint a ]

        SetContext a ->
            [ account <| Account.HandleSetContext a ]

        Notify ->
            []

        NewGateway a ->
            [ account <| Account.HandleNewGateway a ]

        PasswordAcquired a b ->
            []

        LogoutAndCrash a ->
            [ account <| Account.HandleLogoutAndCrash a ]

        Logout ->
            [ account <| Account.HandleLogout ]
