module Game.Account.Update exposing (..)


import Utils
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Account.Messages exposing (AccountMsg(..))
import Game.Account.Models exposing (setToken, getToken, AccountModel)
import Game.Requests exposing (responseHandler
                              , requestLogout)



update : AccountMsg -> AccountModel -> GameModel -> (AccountModel, Cmd GameMsg, List GameMsg)
update msg model game =
    case msg of

        Login token ->
            let
                model_ = setToken model token
            in
                (model_, Cmd.none, [])

        Logout ->
            let
                cmd = requestLogout (Utils.maybeToString (getToken model))
                model_ = setToken model Nothing
            in
                (model_, cmd, [])

