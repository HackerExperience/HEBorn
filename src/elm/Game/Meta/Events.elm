module Game.Meta.Events exposing (..)


import Events.Models exposing (Event(..))


metaEventHandler model event =
    case event of

        EventMyCool ->
            let
                online_ = model.online + 1
                f = Debug.log "setting" (toString online_)
            in
                ({model | online = online_}, Cmd.none)

        _ ->
            (model, Cmd.none)
