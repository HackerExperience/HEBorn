module Events.Account exposing (Event(..), AccountHolder, handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , andThen
        , succeed
        , fail
        , maybe
        , list
        , string
        , value
        )
import Json.Decode.Pipeline exposing (decode, optional)
import Utils.Events exposing (Router, Handler, parse, notify)
import Game.Servers.Shared as Servers
import Game.Account.Models as Database exposing (Model, Email)
import Game.Account.Database.Models as Database
import Game.Account.Dock.Models as Dock
import Game.Account.Bounces.Models as Bounces
import Game.Account.Inventory.Models as Inventory
import Events.Account.Bounces as Bounces
import Events.Account.Database as Database
import Events.Account.Dock as Dock
import Events.Account.Inventory as Inventory


type Event
    = Changed AccountHolder
    | BouncesEvent Bounces.Event
    | DatabaseEvent Database.Event
    | DockEvent Dock.Event
    | InventoryEvent Inventory.Event


type alias AccountHolder =
    { email : Maybe Email
    , database : Maybe Value
    , dock : Maybe Dock.Model
    , servers : List Servers.ID
    , activeGateway : Servers.ID
    , bounces : Maybe Bounces.Model
    , inventory : Maybe Inventory.Model
    }


handler : Router Event
handler context event json =
    case parse event of
        ( Just "bounce", event ) ->
            Maybe.map BouncesEvent <| Bounces.handler event json

        ( Just "database", event ) ->
            Maybe.map DatabaseEvent <| Database.handler event json

        ( Just "dock", event ) ->
            Maybe.map DockEvent <| Dock.handler event json

        ( Just "inventory", event ) ->
            Maybe.map InventoryEvent <| Inventory.handler event json

        ( Just "account", "changed" ) ->
            onChanged json

        _ ->
            Nothing


decoder : Decoder AccountHolder
decoder =
    decode AccountHolder
        |> optional "email" (maybe string) Nothing
        |> optional "database" (maybe value) Nothing
        |> optional "dock" (maybe Dock.decoder) Nothing
        |> optional "servers" (list string) []
        |> optional "active_gateway" string invalidGateway
        |> optional "bounces" (maybe Bounces.decoder) Nothing
        |> optional "inventory" (maybe Inventory.decoder) Nothing
        |> andThen requireActiveGateway



-- internals


invalidGateway : String
invalidGateway =
    ""


onChanged : Handler Event
onChanged json =
    decodeValue decoder json
        |> Result.map Changed
        |> notify


requireActiveGateway : AccountHolder -> Decoder AccountHolder
requireActiveGateway ({ servers, activeGateway } as acc) =
    if activeGateway == invalidGateway then
        case List.head servers of
            Just head ->
                succeed { acc | activeGateway = head }

            _ ->
                fail "Player must have at least one server"
    else
        succeed acc
