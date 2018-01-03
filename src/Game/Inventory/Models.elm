module Game.Inventory.Models exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Components.Specs as Specs exposing (Specs)
import Game.Meta.Types.Network.Connections as NetConnections exposing (Connections)
import Game.Inventory.Shared exposing (..)


type alias Model =
    { components : Components
    , ncs : Connections
    , specs : Specs
    }


initialModel : Model
initialModel =
    { components = Components.empty
    , ncs = NetConnections.empty
    , specs = Specs.empty
    }


getSpecs : Model -> Specs
getSpecs =
    .specs


getComponent : Components.Id -> Model -> Maybe Components.Component
getComponent id model =
    Components.get id model.components


insertComponent : Components.Id -> Components.Component -> Model -> Model
insertComponent id component model =
    let
        components =
            Components.insert id component model.components
    in
        { model | components = components }


removeComponent : Components.Id -> Model -> Model
removeComponent id model =
    let
        components =
            Components.remove id model.components
    in
        { model | components = components }


getNC : NetConnections.Id -> Model -> Maybe NetConnections.Connection
getNC id model =
    NetConnections.get id model.ncs


insertNC : NetConnections.Id -> NetConnections.Connection -> Model -> Model
insertNC id connection model =
    let
        ncs =
            NetConnections.insert id connection model.ncs
    in
        { model | ncs = ncs }


removeNC : NetConnections.Id -> Model -> Model
removeNC id model =
    let
        ncs =
            NetConnections.remove id model.ncs
    in
        { model | ncs = ncs }


setAvailability : Bool -> Entry -> Model -> Model
setAvailability available entry model =
    case entry of
        Component id ->
            case getComponent id model of
                Just component ->
                    insertComponent id
                        (Components.setAvailable False component)
                        model

                Nothing ->
                    model

        NetConnection id ->
            case getNC id model of
                Just connection ->
                    insertNC id
                        (NetConnections.setAvailable False connection)
                        model

                Nothing ->
                    model


isAvailable : Entry -> Model -> Maybe Bool
isAvailable entry model =
    case entry of
        Component id ->
            model
                |> getComponent id
                |> Maybe.map Components.isAvailable

        NetConnection id ->
            model
                |> getNC id
                |> Maybe.map NetConnections.isAvailable


{-| Groups Inventory by component type and availability state,
the firt item of the tuple holds available components, the second
one holds currently used components.
-}
group : (Entry -> Bool) -> Model -> Groups
group isAvailable model =
    let
        groupBy =
            groupHelper isAvailable

        reduceComponents id component group =
            groupBy (Components.typeToString <| Components.getType component)
                (Component id)
                group

        reduceConnections id _ group =
            groupBy "Network Connections" (NetConnection id) group

        appendFold func =
            flip <| Dict.foldl func
    in
        model.components
            |> Dict.foldl reduceComponents Dict.empty
            |> appendFold reduceConnections model.ncs



-- internals


groupHelper :
    (Entry -> Bool)
    -> String
    -> Entry
    -> Groups
    -> Groups
groupHelper isAvailable key entry groups =
    let
        ( free, using ) =
            groups
                |> Dict.get key
                |> Maybe.withDefault ( [], [] )

        value =
            if isAvailable entry then
                ( entry :: free, using )
            else
                ( free, entry :: using )
    in
        Dict.insert key value groups
