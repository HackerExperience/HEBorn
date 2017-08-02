module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Game.Models as Game
import Game.Web.Models exposing (..)
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.Requests exposing (..)
import Game.Web.Requests.DNS as DNS


update :
    Game.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
        Load url ->
            let
                site =
                    get url model
            in
                case site.type_ of
                    Unknown ->
                        let
                            cmd =
                                DNS.request url game
                        in
                            ( model, cmd, Dispatch.none )

                    _ ->
                        ( model, Cmd.none, Dispatch.none )

        Refresh url ->
            let
                model_ =
                    remove url model

                cmd =
                    DNS.request url game
            in
                ( model_, cmd, Dispatch.none )

        Request data ->
            response game (receive data) model

        Event data ->
            event game data model



-- internals


response :
    Game.Model
    -> Response
    -> Model
    -> ( Model, Cmd msg, Dispatch )
response game response model =
    case response of
        DNSResponse (DNS.OkResponse site) ->
            let
                model_ =
                    refresh site.url site model
            in
                ( model_, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


event :
    Game.Model
    -> Events.Event
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
event game ev model =
    case ev of
        _ ->
            ( model, Cmd.none, Dispatch.none )
