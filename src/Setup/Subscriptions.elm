module Setup.Subscriptions exposing (subscriptions)

import Setup.Models exposing (..)
import Setup.Config exposing (..)
import Setup.Pages.PickLocation.Subscriptions as PickLocation


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    case model.page of
        Just (PickLocationModel model) ->
            PickLocation.subscriptions (pickLocationConfig config) model

        _ ->
            Sub.none
