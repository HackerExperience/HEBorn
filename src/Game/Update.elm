module Game.Update exposing (..)

import Core.Messages as Core
import Game.Models exposing (..)
import Game.Messages exposing (..)
import Game.Account.Update as Account
import Game.Account.Messages as Account
import Game.Servers.Update as Servers
import Game.Servers.Messages as Servers
import Game.Network.Update as Network
import Game.Network.Messages as Network
import Game.Meta.Update as Meta
import Game.Meta.Messages as Meta


update : Msg -> Model -> ( Model, Cmd Msg, List Core.Msg )
update msg model =
    case msg of
        AccountMsg msg ->
            account msg model

        ServersMsg msg ->
            servers msg model

        NetworkMsg msg ->
            network msg model

        MetaMsg msg ->
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
    Account.Msg
    -> Model
    -> ( Model, Cmd Msg, List Core.Msg )
account msg model =
    let
        ( account, cmd, msgs ) =
            Account.update msg model.account model

        model_ =
            { model | account = account }

        cmd_ =
            Cmd.map AccountMsg cmd
    in
        ( model_, cmd_, msgs )


servers :
    Servers.Msg
    -> Model
    -> ( Model, Cmd Msg, List Core.Msg )
servers msg model =
    let
        ( servers, cmd, msgs ) =
            Servers.update msg model.servers model

        model_ =
            { model | servers = servers }
    in
        ( model_, cmd, msgs )


network :
    Network.Msg
    -> Model
    -> ( Model, Cmd Msg, List Core.Msg )
network msg model =
    let
        ( network, cmd, msgs ) =
            Network.update msg model.network model

        model_ =
            { model | network = network }
    in
        ( model_, cmd, msgs )


meta : Meta.Msg -> Model -> ( Model, Cmd Msg, List Core.Msg )
meta msg model =
    let
        ( meta, cmd, msgs ) =
            Meta.update msg model.meta model

        model_ =
            { model | meta = meta }
    in
        ( model_, cmd, msgs )


andThen :
    (Model -> ( Model, Cmd Msg, List Core.Msg ))
    -> ( Model, Cmd Msg, List Core.Msg )
    -> ( Model, Cmd Msg, List Core.Msg )
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
