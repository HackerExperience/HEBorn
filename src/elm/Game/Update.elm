module Game.Update exposing (..)


import Update.Extra as Update

import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Requests exposing (responseHandler)

import Game.Account.Update
import Game.Server.Update
import Game.Network.Update
import Game.Software.Update


update : GameMsg -> GameModel -> (GameModel, Cmd GameMsg)
update msg model =
    case msg of

        MsgAccount subMsg ->
            let
                (account_, cmd, gameMsg) =
                    Game.Account.Update.update subMsg model.account model
            in
                ({model | account = account_}, cmd)
                    |> Update.andThen update (getGameMsg gameMsg)

        MsgServer subMsg ->
            let
                (server_, cmd, gameMsg) =
                    Game.Server.Update.update subMsg model.server model
            in
                ({model | server = server_}, cmd)
                    |> Update.andThen update (getGameMsg gameMsg)

        MsgSoftware subMsg ->
            let
                (software_, cmd, gameMsg) =
                    Game.Software.Update.update subMsg model.software model
            in
                ({model | software = software_}, cmd)
                    |> Update.andThen update (getGameMsg gameMsg)

        MsgNetwork subMsg ->
            let
                (network_, cmd, gameMsg) =
                    Game.Network.Update.update subMsg model.network model
            in
                ({model | network = network_}, cmd)
                    |> Update.andThen update (getGameMsg gameMsg)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            let
                (model_, cmd, gameMsg) =
                    responseHandler request data model
            in
                (model_, cmd)
                    |> Update.andThen update (getGameMsg gameMsg)

        NoOp ->
            (model, Cmd.none)


getGameMsg : List GameMsg -> GameMsg
getGameMsg msg =
    case msg of
        [] ->
            NoOp
        m :: _ ->
            m
