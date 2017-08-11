module Events.Account exposing (Event(..), AccountHolder, handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , maybe
        , list
        , string
        )
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Events exposing (Router, Handler, parse, notify)
import Game.Servers.Shared as Servers
import Game.Account.Models as Database exposing (Model, Email)
import Game.Account.Database.Models as Database exposing (Database)
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
        |> required "email" (maybe string)
        |> required "database" Database.decoder
        |> required "dock" Dock.decoder
        |> required "servers" (list string)
        |> required "bounces" Bounces.decoder
        |> required "inventory" Inventory.decoder



-- internals


onChanged : Handler Event
onChanged json =
    decodeValue decoder json
        |> Result.map Changed
        |> notify


type alias AccountHolder =
    { email : Maybe Email
    , database : Database
    , dock : Dock.Model
    , servers : List Servers.ID
    , bounces : Bounces.Model
    , inventory : Inventory.Model
    }
