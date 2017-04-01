module App.Messages exposing (Msg(..)
                             , EventBinds, eventBinds
                             , RequestBinds, requestBinds)

import App.Login.Messages
import App.SignUp.Messages
import App.Core.Messages
import Navigation exposing (Location)
import Events.Models exposing (Event)
import Requests.Models exposing (Request, RequestStoreData, Response, ResponseDecoder)


type Msg
    = MsgCore App.Core.Messages.CoreMsg
    | MsgLogin App.Login.Messages.Msg
    | MsgSignUp App.SignUp.Messages.Msg
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
    { login : Event -> App.Login.Messages.Msg
    , signUp : Event -> App.SignUp.Messages.Msg
    }

eventBinds : EventBinds
eventBinds =
    { login = App.Login.Messages.Event
    , signUp = App.SignUp.Messages.Event
    }

{-
RequestBinds - See description for EventBinds, same rationale. -}

type alias RequestBinds =
    { login : Request -> Response -> App.Login.Messages.Msg
    , signUp : Request -> Response -> App.SignUp.Messages.Msg
    }


requestBinds : RequestBinds
requestBinds =
    { login = App.Login.Messages.Response
    , signUp = App.SignUp.Messages.Response
    }
