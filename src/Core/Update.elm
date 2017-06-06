module Core.Update exposing (update)

import Update.Extra as Update
import Utils
import Router.Router exposing (parseLocation)
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Update as OS
import Game.Update
import Landing.Update
import Driver.Websocket.Update


logMsg : a -> a
logMsg =
    Debug.log "Message: "


update : CoreMsg -> CoreModel -> ( CoreModel, Cmd CoreMsg )
update msg model =
    case (logMsg msg) of
        -- Game messages
        MsgGame subMsg ->
            let
                ( game_, cmd, coreMsg ) =
                    Game.Update.update
                        subMsg
                        model.game
            in
                ( { model | game = game_ }, Cmd.map MsgGame cmd )
                    |> Update.addCmd (batchMsgs coreMsg)

        -- OS messages
        MsgOS msg ->
            let
                ( os, cmd, coreMsg ) =
                    OS.update msg model.game model.os

                model_ =
                    { model | os = os }
            in
                ( model_, Cmd.map MsgOS cmd )
                    |> Update.addCmd (batchMsgs coreMsg)

        -- Landing messages
        MsgLand subMsg ->
            let
                ( landing_, cmd, coreMsg ) =
                    Landing.Update.update subMsg model.landing model
            in
                ( { model | landing = landing_ }, Cmd.map MsgLand cmd )
                    |> Update.addCmd (batchMsgs coreMsg)

        -- Channel
        MsgWebsocket subMsg ->
            let
                ( websocket_, cmd, coreMsg ) =
                    Driver.Websocket.Update.update subMsg model.websocket model
            in
                ( { model | websocket = websocket_ }, Cmd.map MsgWebsocket cmd )
                    |> Update.addCmd (batchMsgs coreMsg)

        -- Router
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        -- Fallback
        _ ->
            ( model, Cmd.none )


{-| Transform multiple Msgs into a single, batched Cmd. We reverse the msg list
so they can get executed in the order they were specified.
-}
batchMsgs : List CoreMsg -> Cmd CoreMsg
batchMsgs msg =
    Cmd.batch
        (List.reverse (List.map Utils.msgToCmd msg))
