module Game.Update exposing (..)


import Utils
import Game.Models.Game exposing (GameModel)
import Game.Models.Account exposing (setToken, getToken)
import Game.Messages exposing (GameMsg(..))
import Game.Requests exposing (responseHandler
                              , requestLogout)


update : GameMsg -> GameModel -> (GameModel, Cmd GameMsg)
update msg model =
    case msg of
        SetToken token ->
            let
                account_ = setToken model.account token
            in
                ({model | account = account_}, Cmd.none)

        Logout ->
            let
                cmd = requestLogout (Utils.maybeToString
                                         (getToken model.account))
                account_ = setToken model.account Nothing
            in
                ({model | account = account_}, cmd)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            responseHandler request data model
