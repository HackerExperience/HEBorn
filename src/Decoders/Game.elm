module Decoders.Game exposing (..)

import Set exposing (Set)
import Json.Decode as Decode
    exposing
        ( Decoder
        , map
        , andThen
        , oneOf
        , succeed
        , string
        , field
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded, optional, custom)
import Game.Account.Models as Account
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Meta.Types exposing (..)
import Game.Meta.Models as Meta
import Game.Storyline.Models as Story
import Game.Web.Models as Web
import Game.Network.Types as Network
import Game.Models exposing (..)
import Decoders.Storyline


type alias ServersToJoin =
    List ServerToJoin


type ServerToJoin
    = JoinPlayer Player
    | JoinRemote Remote


type alias Player =
    { serverId : String
    , networkId : String
    , ip : String
    }


type alias Remote =
    { password : String
    , networkId : String
    , ip : String
    }


bootstrap : Model -> Decoder ( Model, ServersToJoin )
bootstrap game =
    decode Model
        |> hardcoded game.account
        |> hardcoded game.servers
        |> hardcoded game.meta
        |> optional "story" Decoders.Storyline.story Story.initialModel
        |> hardcoded game.web
        |> hardcoded game.config
        |> map (,)
        |> andThen (\done -> map done <| servers)
        |> map (uncurry insertServers)


servers : Decoder ServersToJoin
servers =
    field "servers" serversToJoin


serversToJoin : Decoder ServersToJoin
serversToJoin =
    decode List.append
        |> required "player" (list <| map JoinPlayer joinPlayer)
        |> required "remote" (list <| map JoinRemote joinRemote)


joinPlayer : Decoder Player
joinPlayer =
    decode Player
        |> required "server_id" string
        |> required "network_id" string
        |> required "ip" string


joinRemote : Decoder Remote
joinRemote =
    decode Remote
        |> required "password" string
        |> required "network_id" string
        |> required "ip" string


insertServers : Model -> ServersToJoin -> ( Model, ServersToJoin )
insertServers model serversToJoin =
    let
        reduceServers server servers =
            case server of
                JoinPlayer data ->
                    let
                        id =
                            Network.toNip data.networkId data.ip
                    in
                        Servers.insertGateway id data.serverId servers

                JoinRemote data ->
                    servers

        model_ =
            serversToJoin
                |> List.foldl reduceServers (getServers model)
                |> (flip setServers model)
    in
        ( model_, serversToJoin )
