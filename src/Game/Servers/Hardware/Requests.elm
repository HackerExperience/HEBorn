module Game.Servers.Hardware.Requests exposing (Response(..), receive)

import Game.Servers.Hardware.Messages exposing (..)
import Game.Servers.Hardware.Requests.UpdateMotherboard as UpdateMotherboard


type Response
    = UpdateMotherboard UpdateMotherboard.Response


receive : RequestMsg -> Maybe Response
receive response =
    case response of
        UpdateMotherboardRequest ( code, data ) ->
            UpdateMotherboard.receive code data
                |> Maybe.map UpdateMotherboard
