module Game.Update exposing (..)

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
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Msg -> Model -> ( Model, Cmd Msg, Dispatch )
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
            ( model, Cmd.none, Dispatch.none )



-- internals


account :
    Account.Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
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
    -> ( Model, Cmd Msg, Dispatch )
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
    -> ( Model, Cmd Msg, Dispatch )
network msg model =
    let
        ( network, cmd, msgs ) =
            Network.update msg model.network model

        model_ =
            { model | network = network }
    in
        ( model_, cmd, msgs )


meta : Meta.Msg -> Model -> ( Model, Cmd Msg, Dispatch )
meta msg model =
    let
        ( meta, cmd, msgs ) =
            Meta.update msg model.meta model

        model_ =
            { model | meta = meta }
    in
        ( model_, cmd, msgs )


andThen :
    (Model -> ( Model, Cmd Msg, Dispatch ))
    -> ( Model, Cmd Msg, Dispatch )
    -> ( Model, Cmd Msg, Dispatch )
andThen func ( model, cmd, dispatch1 ) =
    let
        ( model_, cmd1, dispatch2 ) =
            func model

        cmd_ =
            Cmd.batch [ cmd, cmd1 ]

        dispatch_ =
            Dispatch.batch [ dispatch1, dispatch2 ]
    in
        ( model_, cmd_, dispatch_ )
