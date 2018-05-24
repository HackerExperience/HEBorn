module Apps.LocationPicker.Subscriptions exposing (..)

import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation
import Apps.LocationPicker.Config exposing (..)
import Apps.LocationPicker.Models exposing (Model)
import Apps.LocationPicker.Messages exposing (Msg(..))


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    Sub.batch
        [ Sub.map config.toMsg <| Leaflet.subscribe LeafletMsg
        , Sub.map config.toMsg <| Geolocation.subscribe GeolocationMsg
        ]
