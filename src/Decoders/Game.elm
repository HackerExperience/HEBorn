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
import Game.Models exposing (..)
import Decoders.Servers
import Decoders.Storyline


-- this is semi updated, player servers may also become network_id / ip


type alias ServersToJoin =
    List ServerToJoin


type ServerToJoin
    = JoinPlayer Servers.ID
    | JoinRemote Remote


type alias Remote =
    { password : String
    , network_id : String
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


servers : Decoder ServersToJoin
servers =
    oneOf [ field "servers" (list serverToJoin), succeed [] ]


serverToJoin : Decoder ServerToJoin
serverToJoin =
    let
        remote =
            decode Remote
                |> required "password" string
                |> required "network_id" string
                |> required "ip" string

        joinPlayer =
            map JoinPlayer string

        joinRemote =
            map JoinRemote remote
    in
        oneOf [ joinPlayer, joinRemote ]
