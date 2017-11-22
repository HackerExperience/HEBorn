module Game.Servers.Hardware.Models exposing (..)

import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


type alias Model =
    { motherboard : Maybe Motherboard
    }


initialModel : Model
initialModel =
    Model Nothing


getMotherboard : Model -> Maybe Motherboard
getMotherboard =
    .motherboard


setMotherboard : Maybe Motherboard -> Model -> Model
setMotherboard motherboard model =
    { model | motherboard = motherboard }
