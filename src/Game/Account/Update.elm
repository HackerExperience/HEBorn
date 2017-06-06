module Game.Account.Update exposing (..)

import Game.Account.Models exposing (..)
import Game.Account.Messages exposing (..)
import Game.Account.Requests exposing (..)
import Game.Models exposing (GameModel)
import Core.Messages exposing (CoreMsg(MsgWebsocket))


update :
    AccountMsg
    -> AccountModel
    -> GameModel
    -> ( AccountModel, Cmd AccountMsg, List CoreMsg )
update msg model game =
    case msg of
        Login token id ->
            let
                model1 =
                    setToken model (Just token)

                model_ =
                    { model1 | id = Just id }
            in
                ( model_, Cmd.none, [] )

        Logout ->
            case getToken model of
                Just token ->
                    let
                        model_ =
                            setToken model Nothing

                        cmd =
                            logout token game.meta.config
                    in
                        ( model, cmd, [] )

                _ ->
                    ( model, Cmd.none, [] )

        Request data ->
            response (handler data) model game


response :
    Response
    -> AccountModel
    -> GameModel
    -> ( AccountModel, Cmd msg, List CoreMsg )
response response model game =
    case response of
        LogoutResponse ->
            ( model, Cmd.none, [] )
