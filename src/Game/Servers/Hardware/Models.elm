module Game.Servers.Hardware.Models exposing (..)

import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


{-| Model de Hardware, por enquanto só tem uma Motherboard.
-}
type alias Model =
    { motherboard : Maybe Motherboard
    }


{-| Model de Hardware inicia sem Motherboard pois este pode ser um server
remoto. Servers remotos não mostram informações sobre hardware por padrão.
-}
initialModel : Model
initialModel =
    Model Nothing


{-| Getter para motherboard.
-}
getMotherboard : Model -> Maybe Motherboard
getMotherboard =
    .motherboard


{-| Setter para motherboard.
-}
setMotherboard : Maybe Motherboard -> Model -> Model
setMotherboard motherboard model =
    { model | motherboard = motherboard }
