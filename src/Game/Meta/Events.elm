module Game.Meta.Events exposing (..)

import Game.Meta.Models exposing (MetaModel)
import Game.Messages exposing (GameMsg)
import Events.Models exposing (Event(..))


metaEventHandler : MetaModel -> Event -> ( MetaModel, Cmd GameMsg )
metaEventHandler model event =
    case event of
        EventMyCool _ ->
            let
                online_ =
                    model.online + 1

                f =
                    Debug.log "setting" (toString online_)
            in
                ( { model | online = online_ }, Cmd.none )

        _ ->
            ( model, Cmd.none )
