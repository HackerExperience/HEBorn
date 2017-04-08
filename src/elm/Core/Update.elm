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
import Core.Models exposing (Model)
import Core.Components exposing (Component(..))
import OS.Messages
import OS.Update
import Game.Update
import Game.Messages
import Apps.Explorer.Update
import Apps.Explorer.Messages
import Apps.Login.Update
import Apps.Login.Messages
import Apps.SignUp.Update
import Apps.SignUp.Messages


update : CoreMsg -> Model -> ( Model, Cmd CoreMsg )
update msg model =
    let
        logMsg =
            Debug.log "Message: "
    in
        case (logMsg msg) of
            -- Game
            MsgGame (Game.Messages.Request (NewRequest requestData)) ->
                makeRequest model requestData ComponentGame

            MsgGame (Game.Messages.ToOS subMsg) ->
                update (MsgOS subMsg) model

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
                    ( os_, cmd ) =
                        OS.Update.update subMsg model.os
                in
                    ( { model | os = os_ }, Cmd.map MsgOS cmd )

            -- Apps
            MsgExplorer (Apps.Explorer.Messages.Request (NewRequest requestData)) ->
                makeRequest model requestData ComponentExplorer

            MsgExplorer subMsg ->
                let
                    ( explorer_, cmd, gameMsg ) =
                        Apps.Explorer.Update.update subMsg model.appExplorer model.game
                in
                    ( { model | appExplorer = explorer_ }, Cmd.map MsgExplorer cmd )
                        |> Update.andThen update (getGameMsg gameMsg)

            MsgLogin (Apps.Login.Messages.Request (NewRequest requestData)) ->
                makeRequest model requestData ComponentLogin

            MsgLogin subMsg ->
                let
                    ( updatedLogin, cmd, gameMsg ) =
                        Apps.Login.Update.update subMsg model.appLogin model.game
                in
                    ( { model | appLogin = updatedLogin }, Cmd.map MsgLogin cmd )
                        |> Update.andThen update (getGameMsg gameMsg)

            MsgSignUp (Apps.SignUp.Messages.Request (NewRequest requestData)) ->
                makeRequest model requestData ComponentSignUp

            MsgSignUp subMsg ->
                let
                    ( updatedSignUp, cmd, gameMsg ) =
                        Apps.SignUp.Update.update subMsg model.appSignUp model.game
                in
                    ( { model | appSignUp = updatedSignUp }, Cmd.map MsgSignUp cmd )
                        |> Update.andThen update (getGameMsg gameMsg)

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
                    |> Update.andThen update (MsgGame (eventBinds.game event))
                    |> Update.andThen update (MsgSignUp (eventBinds.signUp event))
                    |> Update.andThen update (MsgLogin (eventBinds.login event))

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
