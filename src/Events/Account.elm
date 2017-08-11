module Events.Account exposing (Event(..), handler)

import Utils.Events exposing (Router, Handler, parse)
import Events.Account.Bounces as Bounces
import Events.Account.Database as Database
import Events.Account.Inventory as Inventory


type Event
    = AccountEvent String AccountEvent


type AccountEvent
    = Changed
    | BouncesEvent Bounces.Event
    | DatabaseEvent Database.Event
    | InventoryEvent Inventory.Event


handler : Router Event
handler context event json =
    case context of
        Just id ->
            Maybe.map (AccountEvent id) <| handleAccount event json

        Nothing ->
            Nothing



-- internals


handleAccount : String -> Handler AccountEvent
handleAccount event json =
    case parse event of
        ( Just "bounce", event ) ->
            Maybe.map BouncesEvent <| Bounces.handler event json

        ( Just "database", event ) ->
            Maybe.map DatabaseEvent <| Database.handler event json

        ( Just "inventory", event ) ->
            Maybe.map InventoryEvent <| Inventory.handler event json

        ( Just "account", "changed" ) ->
            onChanged json

        _ ->
            Nothing


onChanged : Handler AccountEvent
onChanged json =
    Just Changed
