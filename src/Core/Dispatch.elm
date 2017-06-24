module Core.Dispatch
    exposing
        ( Dispatch
        , batch
        , none
        , foldl
        , foldr
        , fromList
        , toList
        , toCmd
        , core
        , websocket
        , game
        , account
        , network
        , server
        , filesystem
        , processes
        , logs
        , meta
        )

import Core.Messages exposing (..)
import Driver.Websocket.Messages as Websocket
import Game.Messages as Game
import Game.Meta.Messages as Meta
import Game.Account.Messages as Account
import Game.Network.Messages as Network
import Game.Servers.Messages as Servers
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Models exposing (ServerID)
import Utils exposing (msgToCmd)


-- opaque type to hide the dispatch magic


type Dispatch
    = Many (List Msg)
    | One Msg
    | None



-- cmd/sub like interface


batch : List Dispatch -> Dispatch
batch list =
    -- tried to make it as fast a possible
    case List.head list of
        Just accum ->
            case List.tail list of
                Just iter ->
                    -- this function **may** need to change into a foldr
                    fromList (List.foldl reducer (toList accum) iter)

                Nothing ->
                    accum

        Nothing ->
            None


none : Dispatch
none =
    None



-- reducers


foldl : (Msg -> acc -> acc) -> acc -> Dispatch -> acc
foldl fun init dispatch =
    case dispatch of
        Many list ->
            List.foldl fun init list

        One msg ->
            fun msg init

        None ->
            init


foldr : (Msg -> acc -> acc) -> acc -> Dispatch -> acc
foldr fun init dispatch =
    case dispatch of
        Many list ->
            List.foldr fun init list

        One msg ->
            fun msg init

        None ->
            init



-- reveals some of the magic (try not using this a lot)


fromList : List Msg -> Dispatch
fromList list =
    case List.head list of
        Just item ->
            case List.tail list of
                Just _ ->
                    Many list

                Nothing ->
                    One item

        Nothing ->
            None


toList : Dispatch -> List Msg
toList dispatch =
    case dispatch of
        Many list ->
            list

        One msg ->
            [ msg ]

        None ->
            []


toCmd : Dispatch -> Cmd Msg
toCmd dispatch =
    -- TODO: check if reversing is really needed
    dispatch
        |> toList
        |> List.reverse
        |> List.map msgToCmd
        |> Cmd.batch



-- dispatchers


core : Msg -> Dispatch
core msg =
    One msg


websocket : Websocket.Msg -> Dispatch
websocket msg =
    core (WebsocketMsg msg)


game : Game.Msg -> Dispatch
game msg =
    core (GameMsg msg)


account : Account.Msg -> Dispatch
account msg =
    game (Game.AccountMsg msg)


network : Network.Msg -> Dispatch
network msg =
    game (Game.NetworkMsg msg)


server : Servers.Msg -> Dispatch
server msg =
    game (Game.ServersMsg msg)


meta : Meta.Msg -> Dispatch
meta msg =
    game (Game.MetaMsg msg)


filesystem : ServerID -> Filesystem.Msg -> Dispatch
filesystem serverID msg =
    server (Servers.FilesystemMsg serverID msg)


processes : ServerID -> Processes.Msg -> Dispatch
processes serverID msg =
    server (Servers.ProcessMsg serverID msg)


logs : ServerID -> Logs.Msg -> Dispatch
logs serverID msg =
    server (Servers.LogMsg serverID msg)



-- internals


reducer : Dispatch -> List Msg -> List Msg
reducer next acc =
    case next of
        Many list ->
            List.foldl (::) acc list

        One msg ->
            msg :: acc

        None ->
            acc
