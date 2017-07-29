module Setup.Subscriptions exposing (subscriptions)

import Game.Models as Game
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Geolocation
import Setup.Models exposing (..)
import Setup.Messages exposing (..)


subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    Sub.batch
        [ Map.mapClick MapClick
        , Geolocation.geoResp GeoResp
        ]
