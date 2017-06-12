module Events.Events exposing (Event(..), Response(..), map, handler)

import Events.Account as Account
import Json.Encode exposing (Value)


type Event
    = AccountEvent Account.Event


type Response
    = AccountEventResponse Account.Response


map : (a -> b) -> List ( String, a ) -> List ( String, b )
map mapper events =
    List.map (\( name, event ) -> ( name, mapper event )) events


handler : Event -> Value -> Response
handler event value =
    case event of
        AccountEvent event ->
            value
                |> Account.handler event
                |> AccountEventResponse
