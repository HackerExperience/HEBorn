module Game.Update exposing (..)

import Game.Models exposing (..)
import Game.Messages exposing (..)
import Game.Account.Update as Account
import Game.Account.Messages as Account
import Game.Servers.Update as Servers
import Game.Servers.Messages as Servers
import Game.Meta.Update as Meta
import Game.Meta.Messages as Meta
import Game.Web.Update as Web
import Game.Web.Messages as Web
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update msg model =
    case msg of
        AccountMsg msg ->
            account msg model

        ServersMsg msg ->
            servers msg model

        MetaMsg msg ->
            meta msg model

        WebMsg msg ->
            web msg model

        Event event ->
            model
                |> account (Account.Event event)
                |> andThen (servers (Servers.Event event))
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
        ( account, cmd, dispatch ) =
            Account.update model msg model.account

        model_ =
            { model | account = account }

        cmd_ =
            Cmd.map AccountMsg cmd
    in
        ( model_, cmd_, dispatch )


servers :
    Servers.Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
servers msg model =
    let
        ( servers, cmd, dispatch ) =
            Servers.update model msg model.servers

        model_ =
            { model | servers = servers }
    in
        ( model_, cmd, dispatch )


meta : Meta.Msg -> Model -> ( Model, Cmd Msg, Dispatch )
meta msg model =
    let
        ( meta, cmd, dispatch ) =
            Meta.update model msg model.meta

        model_ =
            { model | meta = meta }
    in
        ( model_, cmd, dispatch )


web : Web.Msg -> Model -> ( Model, Cmd Msg, Dispatch )
web msg model =
    let
        ( web, cmd, dispatch ) =
            Web.update model msg model.web

        model_ =
            { model | web = web }

        cmd_ =
            Cmd.map WebMsg cmd
    in
        ( model_, cmd_, dispatch )


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
