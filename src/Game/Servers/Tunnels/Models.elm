module Game.Servers.Tunnels.Models
    exposing
        ( Model
        , Tunnels
        , ID
        , IP
        , Tunnel
        , Connections
        , ConnectionID
        , Connection
        , ConnectionType(..)
        , initialModel
        , new
        , select
        , get
        , insert
        , remove
        , getEndpoint
        , setEndpoint
        , getConnections
        , setConnections
        , insertConnection
        , removeConnection
        )

import Dict exposing (Dict)
import Game.Account.Bounces.Models as Bounces


type alias Model =
    { tunnels : Tunnels
    , active : Maybe ID
    }


type alias Tunnels =
    Dict ID Tunnel


type alias ID =
    String


type alias IP =
    String


type alias Tunnel =
    { endpoint : IP
    , bounce : Maybe Bounces.ID
    , connections : Connections
    }


type alias Connections =
    Dict ConnectionID Connection


type alias ConnectionID =
    String


type alias Connection =
    -- this may receive more data as we integrate things
    { type_ : ConnectionType }


type ConnectionType
    = ConnectionFTP
    | ConnectionSSH
    | ConnectionX11
    | ConnectionUnknown


initialModel : Model
initialModel =
    { tunnels = Dict.empty
    , active = Nothing
    }


new : IP -> IP -> Model -> Tunnel
new gateway endpoint model =
    case get model of
        Just tunnel ->
            { endpoint = endpoint
            , bounce = tunnel.bounce
            , connections = Dict.empty
            }

        Nothing ->
            { endpoint = endpoint
            , bounce = Nothing
            , connections = Dict.empty
            }


select : Maybe ID -> Model -> Model
select id model =
    { model | active = id }


get : Model -> Maybe Tunnel
get ({ active } as model) =
    case active of
        Just id ->
            Dict.get id model.tunnels

        Nothing ->
            Nothing


insert : ID -> Tunnel -> Model -> Model
insert id tunnel model =
    { model | tunnels = Dict.insert id tunnel model.tunnels }


remove : ID -> Model -> Model
remove id model =
    { model | tunnels = Dict.remove id model.tunnels }


getEndpoint : Model -> Maybe IP
getEndpoint ({ active, tunnels } as model) =
    active
        |> Maybe.andThen (flip Dict.get tunnels)
        |> Maybe.map .endpoint


setEndpoint : IP -> Model -> Model
setEndpoint ip ({ active, tunnels } as model) =
    case active of
        Just aID ->
            case Dict.get aID tunnels of
                Just tunnel ->
                    let
                        tunnel_ =
                            { tunnel | endpoint = ip }

                        tunnels_ =
                            Dict.insert aID tunnel_ tunnels

                        model_ =
                            { model | tunnels = tunnels_ }
                    in
                        model_

                Nothing ->
                    model

        Nothing ->
            model


getConnections : Model -> Connections
getConnections ({ active, tunnels } as model) =
    active
        |> Maybe.andThen (flip Dict.get tunnels)
        |> Maybe.map .connections
        |> Maybe.withDefault Dict.empty


setConnections : Connections -> Model -> Model
setConnections connections ({ active, tunnels } as model) =
    case active of
        Just aID ->
            case Dict.get aID tunnels of
                Just tunnel ->
                    let
                        tunnel_ =
                            { tunnel | connections = connections }

                        tunnels_ =
                            Dict.insert aID tunnel_ tunnels

                        model_ =
                            { model | tunnels = tunnels_ }
                    in
                        model_

                Nothing ->
                    model

        Nothing ->
            model


insertConnection : ConnectionID -> Connection -> Model -> Model
insertConnection id connection ({ active, tunnels } as model) =
    case active of
        Just aID ->
            case Dict.get aID tunnels of
                Just ({ connections } as tunnel) ->
                    let
                        connections_ =
                            Dict.insert id connection connections

                        tunnel_ =
                            { tunnel | connections = connections_ }

                        tunnels_ =
                            Dict.insert aID tunnel_ tunnels

                        model_ =
                            { model | tunnels = tunnels_ }
                    in
                        model_

                Nothing ->
                    model

        Nothing ->
            model


removeConnection : ConnectionID -> Model -> Model
removeConnection id ({ active, tunnels } as model) =
    case active of
        Just aID ->
            case Dict.get aID tunnels of
                Just ({ connections } as tunnel) ->
                    let
                        connections_ =
                            Dict.remove id connections

                        tunnel_ =
                            { tunnel | connections = connections_ }

                        tunnels_ =
                            Dict.insert aID tunnel_ tunnels

                        model_ =
                            { model | tunnels = tunnels_ }
                    in
                        model_

                Nothing ->
                    model

        Nothing ->
            model
