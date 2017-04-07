module Core.Messages exposing (Msg(..)
                              , EventBinds, eventBinds
                              , RequestBinds, requestBinds, getRequestMsg)


import Game.Messages
import OS.Messages
import Apps.Login.Messages
import Apps.SignUp.Messages
import Navigation exposing (Location)
import Events.Models exposing (Event)
import Requests.Models exposing (Request, RequestStoreData, Response, ResponseDecoder)
import Core.Components exposing (..)


type Msg
    = MsgGame Game.Messages.GameMsg
    | MsgOS OS.Messages.OSMsg
    | MsgLogin Apps.Login.Messages.Msg
    | MsgSignUp Apps.SignUp.Messages.Msg
    | OnLocationChange Location
    | DispatchEvent Event
    | DispatchResponse RequestStoreData (String, Int)
    | WSReceivedMessage String
    | NoOp

{-
EventBinds - Hash that maps each Component's Event type to the relevant Msg.
In other words: When we want to send an event to a component, we need to use
that component's Event type. Each component expects its own component type.
To avoid hardcoding the component Event, we create this EventBinds type, which
maps the component to its own event type. -}

type alias EventBinds =
    { game : Event -> Game.Messages.GameMsg
    , os : Event -> OS.Messages.OSMsg
    , login : Event -> Apps.Login.Messages.Msg
    , signUp : Event -> Apps.SignUp.Messages.Msg
    }


eventBinds : EventBinds
eventBinds =
    { game = Game.Messages.Event
    , os= OS.Messages.Event
    , login = Apps.Login.Messages.Event
    , signUp = Apps.SignUp.Messages.Event
    }


{-
RequestBinds - See description for EventBinds, same rationale. -}

type alias RequestBinds =
    { game : Request -> Response -> Game.Messages.GameMsg
    , os : Request -> Response -> OS.Messages.OSMsg
    , login : Request -> Response -> Apps.Login.Messages.Msg
    , signUp : Request -> Response -> Apps.SignUp.Messages.Msg
    }


requestBinds : RequestBinds
requestBinds =
    { game = Game.Messages.Response
    , os = OS.Messages.Response
    , login = Apps.Login.Messages.Response
    , signUp = Apps.SignUp.Messages.Response
    }


getRequestMsg : Component -> Request -> Response -> Msg
getRequestMsg component request response =
    case component of
        ComponentGame ->
            MsgGame (requestBinds.game request response)

        ComponentSignUp ->
          MsgSignUp (requestBinds.signUp request response)

        ComponentLogin ->
            MsgLogin (requestBinds.login request response)

        ComponentOS->
            MsgOS (requestBinds.os request response)

        ComponentInvalid ->
            NoOp
