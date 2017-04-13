module Game.Account.Update exposing (..)

import Utils
import Core.Messages exposing (CoreMsg(MsgChannel))
import Driver.Websocket.Messages exposing (Msg(UpdateSocketParams, JoinChannel, NewMsg))
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg)
import Game.Account.Messages exposing (AccountMsg(..))
import Game.Account.Models exposing (setToken, getToken, AccountModel)
import Game.Account.Requests exposing (requestLogout)


update : AccountMsg -> AccountModel -> GameModel -> ( AccountModel, Cmd GameMsg, List CoreMsg )
update msg model game =
    case msg of
        Login data ->
            let
                { token, account_id } =
                    data

                model_ =
                    setToken model (Just token)

                coreCmd =
                    [ MsgChannel
                        (UpdateSocketParams ( token, account_id ))
                    , MsgChannel
                        (JoinChannel ( "account:" ++ account_id, "notification", "a" ))
                    , MsgChannel
                        (JoinChannel ( "requests", "requests", "a" ))
                    ]
            in
                ( { model_ | id = Just account_id }, Cmd.none, coreCmd )

        Logout ->
            let
                cmd =
                    requestLogout
                        (Utils.maybeToString model.id)
                        (Utils.maybeToString (getToken model))

                -- model_ =
                -- setToken model Nothing
            in
                ( model, cmd, [] )
