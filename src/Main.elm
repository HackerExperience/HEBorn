module Main exposing (init, main)

import Html
import Core.Subscriptions exposing (subscriptions)
import Core.Messages exposing (Msg)
import Core.Models as Core exposing (Model)
import Core.Update exposing (update)
import Core.View exposing (view)
import Core.Flags as Core


-- import TimeTravel.Navigation


type alias Flags =
    { seed : Int
    , apiHttpUrl : String
    , apiWsUrl : String
    , version : String
    }


init : Flags -> ( Model, Cmd Msg )
init { seed, apiHttpUrl, apiWsUrl, version } =
    Core.init seed <| Core.initFlags apiHttpUrl apiWsUrl version


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
