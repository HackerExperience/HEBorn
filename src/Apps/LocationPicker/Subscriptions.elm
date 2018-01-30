module Apps.LocationPicker.Subscriptions exposing (..)

import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocResp)
import Apps.LocationPicker.Config exposing (..)
import Apps.LocationPicker.Models exposing (Model)
import Apps.LocationPicker.Messages exposing (Msg(..))


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    Sub.batch
        [ Map.mapClick (MapClick >> config.toMsg)
        , geoLocResp (GeoResp >> config.toMsg)
        ]
