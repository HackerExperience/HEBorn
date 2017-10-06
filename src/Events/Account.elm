module Events.Account exposing (Event(..), AccountHolder, handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , andThen
        )
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Events exposing (Router, parse)
import Game.Servers.Shared as Servers
import Game.Account.Database.Models as Database
import Game.Account.Dock.Models as Dock
import Game.Account.Bounces.Models as Bounces
import Game.Account.Inventory.Models as Inventory
import Game.Notifications.Models as Notifications
import Game.Storyline.Models as Story
import Decoders.Storyline as Story
import Events.Account.Bounces as Bounces
import Events.Account.Dock as Dock
import Events.Account.Inventory as Inventory
import Events.Account.Database as Database
import Events.Storyline.Missions as Missions
import Events.Storyline.Emails as Emails


type Event
    = BouncesEvent Bounces.Event
    | DatabaseEvent Database.Event
    | DockEvent Dock.Event
    | InventoryEvent Inventory.Event
    | MissionsEvent Missions.Event
    | EmailsEvent Emails.Event


type alias AccountHolder =
    { story : Story.Model
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

        ( Just "story", event ) ->
            Maybe.map MissionsEvent <| Missions.handler event json

        ( Just "email", event ) ->
            Maybe.map EmailsEvent <| Emails.handler event json

        _ ->
            Nothing


decoder : Decoder AccountHolder
decoder =
    decode AccountHolder
        |> required "storyline" Story.story
