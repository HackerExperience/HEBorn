module Game.Meta.Types.Components.Motherboard.Diff exposing (Diff, diff)

import Dict exposing (Dict)
import Set exposing (Set)
import Game.Inventory.Shared as Inventory
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Meta.Types.Components as Components
import Game.Meta.Types.Network.Connections as NetConnections


type alias Diff =
    ( List Inventory.Entry, List Inventory.Entry )


type alias InternalDiff comparable =
    ( Set comparable, Set comparable )


type alias Id =
    String


diff :
    Motherboard
    -> Motherboard
    -> Diff
diff next previous =
    -- perform the whole diff thing
    let
        slots =
            previous
                |> toLinkedComponents
                |> diffHelper (toLinkedComponents next)
                |> fromInternalDiff
                |> map Inventory.Component

        ncs =
            previous
                |> Motherboard.getNCs
                |> diffHelper (Motherboard.getNCs next)
                |> fromInternalDiff
                |> map Inventory.NetConnection
    in
        join slots ncs



-- internals


{-| Perform a smarter comparison that includes slots not present in the new
motherboard.
-}
diffHelper :
    Dict comparable1 comparable2
    -> Dict comparable1 comparable2
    -> InternalDiff comparable2
diffHelper next previous =
    next
        |> Dict.diff previous
        |> Dict.values
        |> List.foldl remove empty
        |> flip (Dict.foldl (diffReducer previous)) next


{-| Compare slot contents with the previous motherboard
-}
diffReducer :
    Dict comparable1 comparable2
    -> comparable1
    -> comparable2
    -> InternalDiff comparable2
    -> InternalDiff comparable2
diffReducer old id component diff =
    case Dict.get id old of
        Just previous ->
            if component /= previous then
                diff
                    |> remove previous
                    |> insert component
            else
                diff

        Nothing ->
            insert component diff


toLinkedComponents : Motherboard -> Dict Motherboard.SlotId Components.Id
toLinkedComponents =
    let
        reducer id slot dict =
            case Motherboard.getSlotComponent slot of
                Just component ->
                    Dict.insert id component dict

                Nothing ->
                    dict
    in
        Motherboard.getSlots >> Dict.foldl reducer Dict.empty


map : (a -> b) -> ( List a, List a ) -> ( List b, List b )
map f ( add, rem ) =
    ( List.map f add, List.map f rem )


{-| An empty diff Set, left is for inserted entries, right for removed entries.
-}
empty : InternalDiff comparable
empty =
    ( Set.empty, Set.empty )


insert : comparable -> InternalDiff comparable -> InternalDiff comparable
insert item ( add, rem ) =
    ( Set.insert item add, Set.remove item rem )


remove : comparable -> InternalDiff comparable -> InternalDiff comparable
remove item ( add, rem ) =
    if Set.member item add then
        ( add, rem )
    else
        ( add, Set.insert item rem )


fromInternalDiff : InternalDiff comparable -> ( List comparable, List comparable )
fromInternalDiff ( add, rem ) =
    ( Set.toList add, Set.toList rem )


join : ( List a, List a ) -> ( List a, List a ) -> ( List a, List a )
join ( add1, rem1 ) ( add2, rem2 ) =
    ( add1 ++ add2
    , rem1 ++ rem2
    )
