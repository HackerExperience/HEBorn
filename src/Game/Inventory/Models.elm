module Game.Inventory.Models exposing (..)

import Dict exposing (Dict)
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Type as Components
import Game.Meta.Types.Components.Specs as Specs exposing (Specs)
import Game.Meta.Types.Network.Connections as Connections exposing (Connections)


type alias Model =
    { components : Components
    , connections : Connections
    , specs : Specs
    }


type Entry
    = Component Components.Id
    | Connection Connections.Id


type alias Group =
    Dict String ( AvailableEntries, UnavailableEntries )


type alias AvailableEntries =
    List Entry


type alias UnavailableEntries =
    List Entry


initialModel : Model
initialModel =
    { components = Components.empty
    , connections = Connections.empty
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


getConnection : Connections.Id -> Model -> Maybe Connections.Connection
getConnection id model =
    Connections.get id model.connections


insertConnection : Connections.Id -> Connections.Connection -> Model -> Model
insertConnection id connection model =
    let
        connections =
            Connections.insert id connection model.connections
    in
        { model | connections = connections }


removeConnection : Connections.Id -> Model -> Model
removeConnection id model =
    let
        connections =
            Connections.remove id model.connections
    in
        { model | connections = connections }


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

        Connection id ->
            case getConnection id model of
                Just connection ->
                    insertConnection id
                        (Connections.setAvailable False connection)
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

        Connection id ->
            model
                |> getConnection id
                |> Maybe.map Connections.isAvailable


{-| Groups Inventory by component type and availability state,
the firt item of the tuple holds available components, the second
one holds currently used components.
-}
group : (Entry -> Bool) -> Model -> Group
group isAvailable model =
    let
        groupBy =
            groupHelper isAvailable

        reduceComponents id component group =
            groupBy (Components.typeToString <| Components.getType component)
                (Component id)
                group

        reduceConnections id _ group =
            groupBy "Connections" (Connection id) group

        appendFold func =
            flip <| Dict.foldl func
    in
        model.components
            |> Dict.foldl reduceComponents Dict.empty
            |> appendFold reduceConnections model.connections



---- internals


groupHelper :
    (Entry -> Bool)
    -> String
    -> Entry
    -> Group
    -> Group
groupHelper isAvailable key entry group =
    let
        ( free, using ) =
            group
                |> Dict.get key
                |> Maybe.withDefault ( [], [] )

        value =
            if isAvailable entry then
                ( entry :: free, using )
            else
                ( free, entry :: using )
    in
        Dict.insert key value group
