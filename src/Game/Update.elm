module Game.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Requests exposing (responseHandler)
import Game.Events exposing (eventHandler)
import Game.Account.Update
import Game.Servers.Update
import Game.Network.Update
import Game.Meta.Update


update : GameMsg -> GameModel -> ( GameModel, Cmd GameMsg, List CoreMsg )
update msg model =
    case msg of
        MsgAccount subMsg ->
            let
                ( account_, cmd, coreMsg ) =
                    Game.Account.Update.update subMsg model.account model
            in
                ( { model | account = account_ }, cmd, coreMsg )

        MsgServers subMsg ->
            let
                ( servers_, cmd, coreMsg ) =
                    Game.Servers.Update.update subMsg model.servers model
            in
                ( { model | servers = servers_ }, cmd, coreMsg )

        MsgNetwork subMsg ->
            let
                ( network_, cmd, coreMsg ) =
                    Game.Network.Update.update subMsg model.network model
            in
                ( { model | network = network_ }, cmd, coreMsg )

        MsgMeta subMsg ->
            let
                ( meta_, cmd, coreMsg ) =
                    Game.Meta.Update.update subMsg model.meta model
            in
                ( { model | meta = meta_ }, cmd, coreMsg )

        Event event ->
            let
                ( model_, cmd, coreMsg ) =
                    eventHandler model event
            in
                ( model_, cmd, coreMsg )

        Request _ ->
            ( model, Cmd.none, [] )

        Response request data ->
            let
                ( model_, cmd, coreMsg ) =
                    responseHandler request data model
            in
                ( model_, cmd, coreMsg )

        NoOp ->
            ( model, Cmd.none, [] )
