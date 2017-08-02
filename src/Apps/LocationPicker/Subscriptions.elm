module Apps.LocationPicker.Subscriptions exposing (..)

import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocResp)
import Game.Data as Game
import Apps.LocationPicker.Models exposing (Model)
import Apps.LocationPicker.Messages exposing (Msg(..))
import Apps.LocationPicker.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.batch
        [ Sub.map MenuMsg (Menu.subscriptions model.menu)
        , Map.mapClick MapClick
        , geoLocResp GeoResp
        ]
