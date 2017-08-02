module Setup.Subscriptions exposing (subscriptions)

import Utils.Ports.Map exposing (mapClick)
import Utils.Ports.Geolocation exposing (geoLocResp, geoRevResp)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ mapClick MapClick
        , geoLocResp GeoLocResp
        , geoRevResp GeoRevResp
        ]
