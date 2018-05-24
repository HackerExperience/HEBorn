module Setup.Pages.PickLocation.Subscriptions exposing (subscriptions)

import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation
import Setup.Pages.PickLocation.Models exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)
import Setup.Pages.PickLocation.Config exposing (..)


subscriptions : Config msg -> Model -> Sub msg
subscriptions { toMsg } model =
    Sub.batch
        [ Sub.map toMsg <| Leaflet.subscribe LeafletMsg
        , Sub.map toMsg <| Geolocation.subscribe GeolocationMsg
        ]
