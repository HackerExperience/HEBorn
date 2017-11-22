module Apps.ServersGears.Models exposing (..)

import Dict exposing (Dict)
import Apps.ServersGears.Menu.Models as Menu
import Game.Data as Game
import Game.Models as Game
import Game.Meta.Types.Components.Motherboard as Motheboard
import Game.Meta.Types.Components.Motherboard.Actions as MotheboardActions exposing (Actions)
import Game.Inventory.Models as Inventory


type alias Model =
    { menu : Menu.Model
    , overrides : Overrides
    , selection : Maybe Selection
    , actions : Actions
    }


type alias Overrides =
    Dict String ( Bool, Inventory.Entry )


type Selection
    = SelectSlot Motheboard.Id
    | SelectInventory Inventory.Entry


name : String
name =
    "Servers Gears"


title : Model -> String
title model =
    "Servers Gears"


icon : String
icon =
    "srvgr"


initialModel : Game.Data -> Model
initialModel game =
    { menu =
        Menu.initialMenu
    , overrides =
        Dict.empty
    , selection =
        Nothing
    , actions =
        MotheboardActions.empty
    }


setAvailability : Inventory.Entry -> Bool -> Inventory.Model -> Model -> Model
setAvailability entry available inventory model =
    let
        key =
            toString entry

        remove () =
            Dict.remove key model.overrides

        insert () =
            Dict.insert key ( available, entry ) model.overrides
    in
        case Inventory.isAvailable entry inventory of
            Just True ->
                if available then
                    { model | overrides = remove () }
                else
                    { model | overrides = insert () }

            Just False ->
                if available then
                    { model | overrides = insert () }
                else
                    { model | overrides = remove () }

            Nothing ->
                model


isAvailable : Inventory.Entry -> Inventory.Model -> Model -> Bool
isAvailable entry inventory model =
    let
        key =
            toString entry
    in
        case Dict.get key model.overrides of
            Just ( state, _ ) ->
                state

            Nothing ->
                inventory
                    |> Inventory.isAvailable entry
                    |> Maybe.withDefault False
