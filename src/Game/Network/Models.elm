module Game.Network.Models
    exposing
        ( Model
        , Connection
        , ConnectionType(..)
        , ID
        , initialModel
        , getServerID
        )

import Dict exposing (Dict)


-- TODO: replace with Server.ID after merging #134


type alias ServerID =
    String


type alias IP =
    String


type alias ID =
    String


type alias BounceID =
    String



-- REVIEW: too many connection prefixes,
-- should this be moved to it's own module?


type ConnectionType
    = ConnectionFTP
    | ConnectionSSH
    | ConnectionX11
    | UnknownConnectionType


type alias Connection =
    { type_ : ConnectionType
    , source_id : ServerID
    , source_ip : IP
    , target_id : ServerID
    , target_ip : IP
    }



-- REVIEW: chain field name may be changed


type alias Bounce =
    { name : String
    , chain : List IP
    }


type alias Bounces =
    Dict BounceID Bounce


type alias ServerMap =
    Dict IP ServerID


type alias Connections =
    Dict ID Connection


type alias Model =
    { gateway : ServerID
    , endpoint : Maybe IP
    , bounce : Maybe BounceID
    , bounces : Bounces
    , serverMap : ServerMap
    , connections : Connections
    }


initialModel : Model
initialModel =
    { gateway = "localhost"
    , endpoint = Nothing
    , bounce = Nothing
    , bounces = Dict.empty
    , serverMap = Dict.empty
    , connections = Dict.empty
    }


getServerID : IP -> Model -> Maybe ServerID
getServerID ip { serverMap } =
    Dict.get ip serverMap


getEndpointID : Model -> Maybe ServerID
getEndpointID ({ endpoint } as model) =
    endpoint |> Maybe.andThen (flip getServerID model)
