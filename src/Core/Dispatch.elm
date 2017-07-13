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
        , servers
        , filesystem
        , processes
        , logs
        , tunnels
        , meta
        , web
        )

import Core.Messages exposing (..)
import Driver.Websocket.Messages as Ws
import Game.Messages as Game
import Game.Meta.Messages as Meta
import Game.Web.Messages as Web
import Game.Account.Messages as Account
import Game.Servers.Messages as Servers
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Servers.Shared as Servers
import Utils.Cmd as CmdUtils


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
        |> List.map CmdUtils.fromMsg
        |> Cmd.batch



-- dispatchers


core : Msg -> Dispatch
core msg =
    One msg


websocket : Ws.Msg -> Dispatch
websocket msg =
    core (WebsocketMsg msg)


game : Game.Msg -> Dispatch
game msg =
    core (GameMsg msg)


account : Account.Msg -> Dispatch
account msg =
    game (Game.AccountMsg msg)


servers : Servers.Msg -> Dispatch
servers msg =
    game (Game.ServersMsg msg)


meta : Meta.Msg -> Dispatch
meta msg =
    game (Game.MetaMsg msg)


filesystem : Servers.ID -> Filesystem.Msg -> Dispatch
filesystem id msg =
    servers (Servers.FilesystemMsg id msg)


processes : Servers.ID -> Processes.Msg -> Dispatch
processes id msg =
    servers (Servers.ProcessMsg id msg)


logs : Servers.ID -> Logs.Msg -> Dispatch
logs id msg =
    servers (Servers.LogMsg id msg)


tunnels : Servers.ID -> Tunnels.Msg -> Dispatch
tunnels id msg =
    servers (Servers.TunnelsMsg id msg)


web : Web.Msg -> Dispatch
web msg =
    game (Game.WebMsg msg)



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
