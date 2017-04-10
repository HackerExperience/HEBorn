module Main exposing (init, main)

import TimeTravel.Navigation
import Navigation exposing (Location)
import Router.Router exposing (parseLocation)
import Core.Subscriptions exposing (subscriptions)
import Core.Messages exposing (CoreMsg(OnLocationChange))
import Core.Models exposing (CoreModel, Flags, initialModel)
import Core.Update exposing (update)
import Core.View exposing (view)


init : Flags -> Location -> ( CoreModel, Cmd CoreMsg )
init flags location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute flags.seed, Cmd.none )



-- main : Program Flags Model Msg


main =
    Navigation.programWithFlags OnLocationChange
        -- TimeTravel.Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
