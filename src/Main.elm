module Main exposing (init, main)

import Html
import Core.Subscriptions exposing (..)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Update exposing (..)
import Core.View exposing (..)
import Core.Config as Config exposing (Config)


-- import TimeTravel.Navigation


type alias Flags =
    { seed : Int
    , apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }


init : Flags -> ( Model, Cmd Msg )
init { seed, apiHttpUrl, apiWsUrl, version } =
    let
        config =
            Config.init apiHttpUrl apiWsUrl version

        model =
            initialModel seed config
    in
        ( model, Cmd.none )


main : Program Flags Model Msg
main =
    {- Toggle comment below to switch on/off TimeTravel debugger. It's a great
       option to debug changes on models (and quickly go back in time to apply
       new changes), but it makes the UI quite sluggish, specially when dragging
       windows, since it has to track all messages. In short, we recommend using
       TimeTravel only when debugging specific models.

    -}
    -- TimeTravel.programWithFlags
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
