module Core.Messages
    exposing
        ( CoreMsg(..)
        , EventBinds
        , eventBinds
        , RequestBinds
        , requestBinds
        , getRequestMsg
        )

import Navigation exposing (Location)
import Events.Models exposing (Event)
import Requests.Models exposing (Request, RequestStoreData, Response, ResponseDecoder)
import Core.Components exposing (..)
import Game.Messages exposing (GameMsg(..))
import OS.Messages exposing (OSMsg(..))
import Apps.Messages exposing (AppMsg(..), appBinds)
import Landing.Messages exposing (LandMsg(..))


type CoreMsg
    = MsgGame Game.Messages.GameMsg
    | MsgOS OS.Messages.OSMsg
    | MsgApp Apps.Messages.AppMsg
    | MsgLand Landing.Messages.LandMsg
    | OnLocationChange Location
    | DispatchEvent Event
    | DispatchResponse RequestStoreData ( String, Int )
    | WSReceivedMessage String
    | NoOp



{-
   EventBinds - Hash that maps each Component's Event type to the relevant Msg.
   In other words: When we want to send an event to a component, we need to use
   that component's Event type. Each component expects its own component type.
   To avoid hardcoding the component Event, we create this EventBinds type, which
   maps the component to its own event type.
-}


type alias EventBinds =
    { game : Event -> Game.Messages.GameMsg
    , os : Event -> OS.Messages.OSMsg
    , apps : Event -> Apps.Messages.AppMsg
    }


eventBinds : EventBinds
eventBinds =
    { game = Game.Messages.Event
    , os = OS.Messages.Event
    , apps = Apps.Messages.Event
    }



{-
   RequestBinds - See description for EventBinds, same rationale.
-}


type alias RequestBinds =
    { game : Request -> Response -> Game.Messages.GameMsg
    , os : Request -> Response -> OS.Messages.OSMsg
    , apps : Request -> Response -> Apps.Messages.AppMsg
    }


requestBinds : RequestBinds
requestBinds =
    { game = Game.Messages.Response
    , os = OS.Messages.Response
    , apps = Apps.Messages.Response
    }


getRequestMsg : Component -> Request -> Response -> CoreMsg
getRequestMsg component request response =
    case component of
        ComponentGame ->
            MsgGame (requestBinds.game request response)

        ComponentOS ->
            MsgOS (requestBinds.os request response)

        ComponentApp ->
            MsgApp (requestBinds.apps request response)

        ComponentInvalid ->
            NoOp

        _ ->
            NoOp
