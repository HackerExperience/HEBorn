module Core.Update exposing (update)

import Update.Extra as Update
import Requests.Models exposing (Request(RequestInvalid, NewRequest))
import Requests.Update exposing (getRequestData, makeRequest, removeRequestId)
import Events.Models exposing (Event(EventUnknown))
import Events.Update exposing (getEvent)
import Router.Router exposing (parseLocation)
import WS.WS exposing (getWSMsgMeta, getWSMsgType)
import WS.Models exposing (WSMsgType(WSResponse, WSEvent, WSInvalid))
import Core.Messages exposing (CoreMsg(..), eventBinds, getRequestMsg)
import Core.Models exposing (CoreModel)
import Core.Components exposing (Component(..))
import OS.Messages
import OS.Update
import Game.Update
import Game.Messages
import Apps.Messages
import Apps.Update


update : CoreMsg -> CoreModel -> ( CoreModel, Cmd CoreMsg )
update msg model =
    let
        logMsg =
            Debug.log "Message: "
    in
        case (logMsg msg) of
            -- Game
            MsgGame (Game.Messages.Request (NewRequest requestData)) ->
                makeRequest model requestData ComponentGame

            MsgGame subMsg ->
                let
                    ( game_, cmd ) =
                        Game.Update.update subMsg model.game
                in
                    ( { model | game = game_ }, Cmd.map MsgGame cmd )

            -- OS
            MsgOS (OS.Messages.Request (NewRequest requestData)) ->
                makeRequest model requestData ComponentOS

            MsgOS subMsg ->
                let
                    ( os_, cmd, coreMsg ) =
                        OS.Update.update subMsg model.os
                in
                    ( { model | os = os_ }, Cmd.map MsgOS cmd )
                        |> Update.andThen update (getCoreMsg coreMsg)

            -- Apps
            MsgApp (Apps.Messages.Request (NewRequest requestData) component) ->
                makeRequest model requestData component

            MsgApp subMsg ->
                let
                    ( apps_, cmd, coreMsg ) =
                        Apps.Update.update subMsg model.apps model
                in
                    ( { model | apps = apps_ }, Cmd.map MsgApp cmd )
                        |> Update.andThen update (getCoreMsg coreMsg)

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

            DispatchResponse ( component, request, decoder ) ( raw, code ) ->
                let
                    response =
                        decoder raw code

                    requestMsg =
                        getRequestMsg component request response
                in
                    update requestMsg model

            -- Websocket
            {-
               Parse the received WebSocket message into the expected format and
               forward it to the relevant dispatcher.
            -}
            WSReceivedMessage message ->
                let
                    wsMsg =
                        getWSMsgMeta message

                    wsMsgType =
                        getWSMsgType wsMsg
                in
                    case wsMsgType of
                        WSResponse ->
                            let
                                requestData =
                                    getRequestData model.requests wsMsg.request_id

                                requests_ =
                                    removeRequestId model.requests wsMsg.request_id

                                model_ =
                                    { model | requests = requests_ }
                            in
                                update (DispatchResponse requestData ( message, wsMsg.code )) model_

                        WSEvent ->
                            update (DispatchEvent (getEvent wsMsg.event)) model

                        WSInvalid ->
                            ( model, Cmd.none )

            -- Misc
            {- Perform no operation -}
            NoOp ->
                ( model, Cmd.none )


getGameMsg : List Game.Messages.GameMsg -> CoreMsg
getGameMsg msg =
    case msg of
        [] ->
            NoOp

        m :: _ ->
            (MsgGame m)


getCoreMsg : List CoreMsg -> CoreMsg
getCoreMsg msg =
    case msg of
        [] ->
            NoOp

        m :: _ ->
            m
