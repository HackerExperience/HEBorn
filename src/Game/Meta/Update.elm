module Game.Meta.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Messages as Game
import Game.Models as Game
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Meta.Types exposing (..)
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Game.Msg, Dispatch )
update game msg model =
    case msg of
        SetGateway id ->
            if List.member id game.account.servers then
                let
                    model1 =
                        { model | gateway = Just id }

                    model_ =
                        ensureValidContext game model1
                in
                    ( model_, Cmd.none, Dispatch.none )
            else
                ( model, Cmd.none, Dispatch.none )

        SetEndpoint nip ->
            let
                setEndpoint id =
                    Dispatch.servers <| Servers.SetEndpoint id nip

                dispatch =
                    model
                        |> getGateway
                        |> Maybe.map setEndpoint
                        |> Maybe.withDefault Dispatch.none

                model_ =
                    if nip == Nothing then
                        ensureValidContext game { model | context = Gateway }
                    else
                        ensureValidContext game model
            in
                ( model_, Cmd.none, dispatch )

        ContextTo context ->
            let
                model1 =
                    { model | context = context }

                model_ =
                    ensureValidContext game model1
            in
                ( model_, Cmd.none, Dispatch.none )

        Tick time ->
            let
                model_ =
                    { model | lastTick = time }
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


ensureValidContext : Game.Model -> Model -> Model
ensureValidContext game model =
    let
        servers =
            Game.getServers game

        endpoint =
            model
                |> getGateway
                |> Maybe.andThen (flip Servers.get servers)
                |> Maybe.andThen Servers.getEndpoint
                |> Maybe.andThen (flip Servers.mapNetwork servers)
                |> Maybe.andThen (flip Servers.get servers)
    in
        if getContext model == Endpoint && endpoint == Nothing then
            { model | context = Gateway }
        else
            model
