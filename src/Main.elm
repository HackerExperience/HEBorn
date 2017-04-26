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
        ( initialModel
            currentRoute
            flags.seed
            flags.apiHttpUrl
            flags.apiWsUrl
        , Cmd.none
        )



-- main : Program Flags CoreModel CoreMsg


main =
    {- Toggle comment below to switch on/off TimeTravel debugger. It's a great
       option to debug changes on models (and quickly go back in time to apply
       new changes), but it makes the UI quite sluggish, specially when dragging
       windows, since it has to track all messages. In short, we recommend using
       TimeTravel only when debugging specific models.

    -}
    Navigation.programWithFlags OnLocationChange
        -- TimeTravel.Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
