module Core.Update exposing (update)

import Update.Extra as Update
import Debug

import Requests.Models exposing (Request(RequestInvalid, NewRequest))
import Requests.Update exposing (getRequestData, makeRequest, removeRequestId)
import Events.Models exposing (Event(EventUnknown))
import Events.Update exposing (getEvent)
import Router.Router exposing (parseLocation)
import WS.WS exposing (getWSMsgMeta, getWSMsgType)
import WS.Models exposing (WSMsgType(WSResponse, WSEvent, WSInvalid))

import Core.Messages exposing (Msg(..), eventBinds, getRequestMsg)
import Core.Models exposing (Model)
import Core.Components exposing (Component(..))
import OS.WindowManager.Update
import OS.WindowManager.Messages
import Game.Update
import Game.Messages
import Apps.Login.Update
import Apps.Login.Messages
import Apps.SignUp.Update
import Apps.SignUp.Messages


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        logMsg =
            Debug.log "Message: "
    in
        case (logMsg msg) of

            -- Game

            MsgGame (Game.Messages.Request (NewRequest (requestData))) ->
                makeRequest model requestData ComponentGame

            MsgGame (Game.Messages.ToWM subMsg) ->
                update (MsgWM subMsg) model

            MsgGame subMsg ->
                let
                    (game_, cmd) =
                        Game.Update.update subMsg model.game
                in
                    ({model | game = game_}, Cmd.map MsgGame cmd)

            -- Window Manager

            MsgWM (OS.WindowManager.Messages.Request (NewRequest (requestData))) ->
                makeRequest model requestData ComponentWM

            MsgWM subMsg ->
                let
                    (wm_, cmd) =
                        OS.WindowManager.Update.update subMsg model.wm model.seed
                in
                    ({model | wm = wm_}, Cmd.map MsgWM cmd)


            -- Apps

            MsgLogin (Apps.Login.Messages.Request (NewRequest (requestData))) ->
                makeRequest model requestData ComponentLogin

            MsgLogin subMsg ->
                let
                    (updatedLogin, cmd, gameMsg) =
                        Apps.Login.Update.update subMsg model.appLogin model.game
                in
                    ({model | appLogin = updatedLogin}, Cmd.map MsgLogin cmd)
                        |> Update.andThen update (getGameMsg gameMsg)

            -- MsgSignUp (Apps.SignUp.Messages.Request (NewRequest (requestData))) ->
            --     makeRequest model requestData ComponentSignUp

            -- MsgSignUp subMsg ->
            --     let
            --         (updatedSignUp, cmd, gameMsg) =
            --             Apps.SignUp.Update.update subMsg model.appSignUp model.game
            --     in
            --         ({model | appSignUp = updatedSignUp}, Cmd.map MsgSignUp cmd)
            --             |> Update.andThen update (getGameMsg gameMsg)
            MsgSignUp _ ->
                (model, Cmd.none)

            -- Router

            OnLocationChange location ->
                let
                    newRoute = parseLocation location
                in
                    ({model | route = newRoute}, Cmd.none)

            -- Dispatchers

            {-
            DispatchEvent is triggered when the server notifies the client
            about any event that happened to the player. The event is sent
            to all components, and it's up to each component to decide what
            to do with it.
            -}
            DispatchEvent EventUnknown ->
                Debug.log "received event is unknown"
                (model, Cmd.none)

            DispatchEvent event ->
                Debug.log "eventoo"
                model ! []
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
            DispatchResponse (_, RequestInvalid, _) _ ->
                Debug.log "received reply never was requested"
                (model, Cmd.none)

            DispatchResponse (component, request, decoder) (raw, code) ->


                let
                    response = decoder raw code
                    requestMsg = getRequestMsg component request response
                in
                    update requestMsg model

            -- Websocket

            {-
            Parse the received WebSocket message into the expected format and
            forward it to the relevant dispatcher.
            -}
            WSReceivedMessage message ->

                let
                    wsMsg = getWSMsgMeta message
                    wsMsgType = getWSMsgType wsMsg
                in
                    case wsMsgType of

                        WSResponse ->
                            let
                                requestData = getRequestData model wsMsg.request_id
                                newModel = removeRequestId model wsMsg.request_id
                            in
                                update (DispatchResponse requestData (message, wsMsg.code)) newModel

                        WSEvent ->
                            update (DispatchEvent (getEvent wsMsg.event)) model

                        WSInvalid ->
                            (model, Cmd.none)

            -- Misc

            {- Perform no operation -}
            NoOp ->
                (model, Cmd.none)


getGameMsg : List Game.Messages.GameMsg -> Msg
getGameMsg msg =
    case msg of
        [] ->
            NoOp
        m :: _ ->
            (MsgGame m)
