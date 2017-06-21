module Main exposing (init, main)

import Navigation exposing (Location)
import Router.Router exposing (parseLocation)
import Core.Subscriptions exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Update exposing (..)
import Core.View exposing (..)


-- import TimeTravel.Navigation


init : Flags -> Location -> ( Model, Cmd Msg )
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
            flags.version
        , Cmd.none
        )


main : Program Flags Model Msg
main =
    {- Toggle comment below to switch on/off TimeTravel debugger. It's a great
       option to debug changes on models (and quickly go back in time to apply
       new changes), but it makes the UI quite sluggish, specially when dragging
       windows, since it has to track all messages. In short, we recommend using
       TimeTravel only when debugging specific models.

    -}
    -- TimeTravel.Navigation.programWithFlags LocationChangeMsg
    Navigation.programWithFlags LocationChangeMsg
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
