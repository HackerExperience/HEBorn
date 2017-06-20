module Game.Update exposing (..)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(..))
import Game.Account.Update as Account
import Game.Account.Messages as Account
import Game.Servers.Update as Servers
import Game.Servers.Messages as Servers
import Game.Network.Update as Network
import Game.Network.Messages as Network
import Game.Meta.Update as Meta
import Game.Meta.Messages as Meta


update : GameMsg -> GameModel -> ( GameModel, Cmd GameMsg, List CoreMsg )
update msg model =
    case msg of
        MsgAccount msg ->
            account msg model

        MsgServers msg ->
            servers msg model

        MsgNetwork msg ->
            network msg model

        MsgMeta msg ->
            meta msg model

        Event event ->
            model
                |> account (Account.Event event)
                |> andThen (servers (Servers.Event event))
                |> andThen (network (Network.Event event))
                |> andThen (meta (Meta.Event event))

        _ ->
            ( model, Cmd.none, [] )



-- internals


account :
    Account.AccountMsg
    -> GameModel
    -> ( GameModel, Cmd GameMsg, List CoreMsg )
account msg model =
    let
        ( account, cmd, msgs ) =
            Account.update msg model.account model

        model_ =
            { model | account = account }

        cmd_ =
            Cmd.map MsgAccount cmd
    in
        ( model_, cmd_, msgs )


servers :
    Servers.Msg
    -> GameModel
    -> ( GameModel, Cmd GameMsg, List CoreMsg )
servers msg model =
    let
        ( servers, cmd, msgs ) =
            Servers.update msg model.servers model

        model_ =
            { model | servers = servers }
    in
        ( model_, cmd, msgs )


network :
    Network.NetworkMsg
    -> GameModel
    -> ( GameModel, Cmd GameMsg, List CoreMsg )
network msg model =
    let
        ( network, cmd, msgs ) =
            Network.update msg model.network model

        model_ =
            { model | network = network }
    in
        ( model_, cmd, msgs )


meta : Meta.MetaMsg -> GameModel -> ( GameModel, Cmd GameMsg, List CoreMsg )
meta msg model =
    let
        ( meta, cmd, msgs ) =
            Meta.update msg model.meta model

        model_ =
            { model | meta = meta }
    in
        ( model_, cmd, msgs )


andThen :
    (GameModel -> ( GameModel, Cmd GameMsg, List CoreMsg ))
    -> ( GameModel, Cmd GameMsg, List CoreMsg )
    -> ( GameModel, Cmd GameMsg, List CoreMsg )
andThen func ( model, cmd, msgs ) =
    let
        ( model_, cmd1, msgs1 ) =
            func model

        cmd_ =
            Cmd.batch [ cmd, cmd1 ]

        msgs_ =
            msgs1 ++ msgs
    in
        ( model_, cmd_, msgs_ )
