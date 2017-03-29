module Main exposing (init, main)

import TimeTravel.Navigation
import Navigation exposing (Location)

import Router.Router exposing (parseLocation)
import App.Subscriptions exposing (subscriptions)
import App.Messages exposing (Msg(OnLocationChange))
import App.Models exposing (Model, Flags, initialModel)
import App.Update exposing (update)
import App.View exposing (view)


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute flags.seed, Cmd.none )


-- main : Program Flags Model Msg
main =
    -- Navigation.programWithFlags OnLocationChange
    TimeTravel.Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
