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
        , os
        , account
        , database
        , servers
        , web
        , mission
        , missionAction
        , email
        , story
        , server
        , filesystem
        , processes
        , logs
        , log
        , tunnels
        , serverNotification
        , accountNotification
        , meta
        , openApp
        , apps
        , appsOfSession
        , browser
        , toasts
        , politeCrash
        )

import Apps.Messages as Apps
import Apps.Apps as Apps
import Apps.Browser.Messages as Browser
import Game.Messages as Game
import Core.Messages exposing (..)
import Driver.Websocket.Messages as Ws
import Game.Data as Game
import Game.Meta.Types exposing (Context(..))
import Game.Meta.Messages as Meta
import Game.Storyline.Messages as Story
import Game.Storyline.Missions.Messages as Missions
import Game.Storyline.Missions.Actions as Missions
import Game.Storyline.Emails.Messages as Emails
import Game.Account.Messages as Account
import Game.Account.Database.Messages as Database
import Game.Notifications.Messages as Notifications
import Game.Servers.Messages as Servers
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Logs.Models as Logs
import Game.Servers.Tunnels.Messages as Tunnels
import Game.Web.Messages as Web
import Game.Servers.Shared as Servers
import OS.Messages as OS
import OS.SessionManager.Messages as SessionManager
import OS.SessionManager.Models exposing (WindowRef)
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.Toasts.Messages as Toasts
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
                    fromList <| List.foldl reducer (toList accum) iter

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
    -- TODO: check if reversing is really needed, ordering
    -- must never be a problem
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
    core <| WebsocketMsg msg


game : Game.Msg -> Dispatch
game msg =
    core <| GameMsg msg


account : Account.Msg -> Dispatch
account msg =
    game <| Game.AccountMsg msg


database : Database.Msg -> Dispatch
database msg =
    account <| Account.DatabaseMsg msg


servers : Servers.Msg -> Dispatch
servers msg =
    game <| Game.ServersMsg msg


meta : Meta.Msg -> Dispatch
meta msg =
    game <| Game.MetaMsg msg


story : Story.Msg -> Dispatch
story msg =
    game <| Game.StoryMsg msg


mission : Missions.Msg -> Dispatch
mission msg =
    story <| Story.MissionsMsg msg


email : Emails.Msg -> Dispatch
email msg =
    story <| Story.EmailsMsg msg


missionAction : Game.Data -> Missions.Action -> Dispatch
missionAction data act =
    if data.game.story.enabled then
        mission <| Missions.ActionDone act
    else
        None


server : Servers.CId -> Servers.ServerMsg -> Dispatch
server cid msg =
    servers <| Servers.ServerMsg cid msg


filesystem : Servers.CId -> Filesystem.Msg -> Dispatch
filesystem cid msg =
    server cid <| Servers.FilesystemMsg msg


processes : Servers.CId -> Processes.Msg -> Dispatch
processes cid msg =
    server cid <| Servers.ProcessesMsg msg


logs : Servers.CId -> Logs.Msg -> Dispatch
logs cid msg =
    server cid <| Servers.LogsMsg msg


log : Servers.CId -> Logs.ID -> Logs.LogMsg -> Dispatch
log serverId cid msg =
    logs serverId <| Logs.LogMsg cid msg


tunnels : Servers.CId -> Tunnels.Msg -> Dispatch
tunnels cid msg =
    server cid <| Servers.TunnelsMsg msg


serverNotification : Servers.CId -> Notifications.Msg -> Dispatch
serverNotification cid msg =
    server cid <| Servers.NotificationsMsg msg


accountNotification : Notifications.Msg -> Dispatch
accountNotification msg =
    account <| Account.NotificationsMsg msg


web : Web.Msg -> Dispatch
web msg =
    game <| Game.WebMsg msg


browser : WindowRef -> Context -> Browser.Msg -> Dispatch
browser windowRef context msg =
    app windowRef context <| Apps.BrowserMsg msg


openApp : Maybe Context -> Apps.App -> Dispatch
openApp context app =
    sessionManager <| SessionManager.OpenApp context app


apps : List Apps.Msg -> Dispatch
apps msgs =
    sessionManager <| SessionManager.EveryAppMsg msgs


appsOfSession :
    Servers.CId
    -> WindowManager.TargetContext
    -> List Apps.Msg
    -> Dispatch
appsOfSession cid context msgs =
    sessionManager <| SessionManager.TargetedAppMsg cid context msgs



-- internals


os : OS.Msg -> Dispatch
os msg =
    core <| OSMsg msg


sessionManager : SessionManager.Msg -> Dispatch
sessionManager msg =
    os <| OS.SessionManagerMsg msg


toasts : Toasts.Msg -> Dispatch
toasts msg =
    os <| OS.ToastsMsg msg


app : WindowRef -> Context -> Apps.Msg -> Dispatch
app windowRef context msg =
    sessionManager <|
        SessionManager.AppMsg
            windowRef
            context
            msg


politeCrash : String -> String -> Dispatch
politeCrash code details =
    core <| Crash code details


reducer : Dispatch -> List Msg -> List Msg
reducer next acc =
    case next of
        Many list ->
            List.foldl (::) acc list

        One msg ->
            msg :: acc

        None ->
            acc
