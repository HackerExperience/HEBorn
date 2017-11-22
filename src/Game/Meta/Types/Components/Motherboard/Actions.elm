module Game.Meta.Types.Components.Motherboard.Actions exposing (..)

import Dict exposing (Dict)
import Game.Inventory.Models as Inventory
import Game.Servers.Hardware.Models as Hardware
import Game.Meta.Types.Components.Type exposing (Type)
import Game.Meta.Types.Components as Components exposing (Components)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Network.Connections as Connections exposing (Connections)


type alias Actions =
    Dict Slot Action


type alias Slot =
    String


type Action
    = Swap (List Inventory.Entry) (List Inventory.Entry)
    | Keep (List Inventory.Entry)


empty : Actions
empty =
    Dict.empty


fromMotherboard : Motherboard -> Actions
fromMotherboard motherboard =
    let
        mapper id component =
            let
                state0 =
                    [ Inventory.Component id ]

                state_ =
                    case Motherboard.getNetwork id motherboard of
                        Just network ->
                            Inventory.Connection network :: state0

                        Nothing ->
                            state0
            in
                Keep state_
    in
        Dict.map mapper <| Motherboard.getSlots motherboard


link : Slot -> List Inventory.Entry -> Actions -> ( Maybe Action, Actions )
link =
    let
        insert id entries actions =
            case entries of
                [] ->
                    ( Nothing
                    , Dict.insert id (Keep []) actions
                    )

                entries ->
                    let
                        action =
                            Swap entries []
                    in
                        ( Just action
                        , Dict.insert id action actions
                        )

        replace id entries old actions =
            if entries == old then
                ( Nothing, actions )
            else
                let
                    action =
                        Swap entries old
                in
                    ( Just action
                    , Dict.insert id action actions
                    )

        action id entries actions =
            case Dict.get id actions of
                Just (Keep []) ->
                    insert id entries actions

                Just (Keep old) ->
                    replace id entries old actions

                Just (Swap _ []) ->
                    insert id entries actions

                Just (Swap _ old) ->
                    replace id entries old actions

                _ ->
                    ( Nothing, actions )
    in
        action


unlink : Slot -> Actions -> ( Maybe Action, Actions )
unlink =
    let
        remove id entries actions =
            case entries of
                [] ->
                    ( Nothing
                    , Dict.insert id (Keep []) actions
                    )

                entries ->
                    let
                        action =
                            Swap [] entries
                    in
                        ( Just action
                        , Dict.insert id action actions
                        )

        action id actions =
            case Dict.get id actions of
                Just (Swap _ []) ->
                    remove id [] actions

                Just (Swap [] entries) ->
                    remove id entries actions

                Just (Keep []) ->
                    ( Nothing, actions )

                Just (Keep entries) ->
                    remove id entries actions

                _ ->
                    ( Nothing, actions )
    in
        action
