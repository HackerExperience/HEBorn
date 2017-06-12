module Core.Update exposing (update)

import Update.Extra as Update
import Utils
import Requests.Models exposing (Request(RequestInvalid, NewRequest), getResponseCode)
import Requests.Update exposing (getRequestData, makeRequest, removeRequestId)
import Events.Models exposing (Event(EventUnknown))
import Router.Router exposing (parseLocation)
import Core.Messages exposing (CoreMsg(..), eventBinds, getRequestMsg)
import Core.Models exposing (CoreModel)
import Core.Components exposing (Component(..))
import OS.Messages
import OS.Update as OS
import Game.Update
import Game.Messages
import Landing.Messages
import Landing.Update
import Driver.Websocket.Update


logMsg : a -> a
logMsg =
    Debug.log "Message: "


update : CoreMsg -> CoreModel -> ( CoreModel, Cmd CoreMsg )
update msg model =
    case (logMsg msg) of
        -- Game
        MsgGame (Game.Messages.Request (NewRequest requestData)) ->
            makeRequest model requestData ComponentGame

        MsgGame subMsg ->
            let
                ( game_, cmd, coreMsg ) =
                    Game.Update.update subMsg model.game
            in
                ( { model | game = game_ }, Cmd.map MsgGame cmd )
                    |> Update.addCmd (batchMsgs coreMsg)

        -- OS
        MsgOS (OS.Messages.Request (NewRequest requestData)) ->
            makeRequest model requestData ComponentOS

        MsgOS msg ->
            let
                ( os, cmd, coreMsg ) =
                    OS.update msg model.game model.os

                model_ =
                    { model | os = os }
            in
                ( model_, Cmd.map MsgOS cmd )
                    |> Update.addCmd (batchMsgs coreMsg)

        -- Landing
        MsgLand (Landing.Messages.Request (NewRequest requestData) component) ->
            makeRequest model requestData component

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

        -- Dispatchers
        {-
           DispatchEvent is triggered when the server notifies the client
           about any event that happened to the player. The event is sent
           to all components, and it's up to each component to decide what
           to do with it.
        -}
        DispatchEvent EventUnknown ->
            Debug.log "received event is unknown"
                ( model, Cmd.none )

        DispatchEvent event ->
            Debug.log "eventoo"
                model
                ! []

        -- |> Update.andThen update (MsgGame (eventBinds.game event))
        -- |> Update.andThen update (MsgSignUp (eventBinds.signUp event))
        -- |> Update.andThen update (MsgLogin (eventBinds.login event))
        -- Responses
        NewResponse ( requestId, code, body ) ->
            let
                requestData =
                    getRequestData model.requests requestId

                requests_ =
                    removeRequestId model.requests requestId

                model_ =
                    { model | requests = requests_ }
            in
                update (DispatchResponse requestData ( code, body ))
                    model_

        {-
           DispatchResponse is triggered when the client sends a message to
           the server and the message is answered. It is the classic
           request-reply model in action. Once the server reply is received,
           we will dispatch the response to the component that made the
           request. Notice how this is totally different from DispatchEvent,
           which will broadcast the message to ALL components.
        -}
        DispatchResponse ( _, RequestInvalid, _ ) _ ->
            Debug.log "received reply never was requested"
                ( model, Cmd.none )

        DispatchResponse ( component, request, decoder ) ( code, body ) ->
            let
                response =
                    decoder body code

                requestMsg =
                    getRequestMsg component request response
            in
                update requestMsg model

        -- Misc
        {- Perform no operation -}
        NoOp ->
            ( model, Cmd.none )


{-| Transform multiple Msgs into a single, batched Cmd. We reverse the msg list
so they can get executed in the order they were specified.
-}
batchMsgs : List CoreMsg -> Cmd CoreMsg
batchMsgs msg =
    Cmd.batch
        (List.reverse (List.map Utils.msgToCmd msg))
