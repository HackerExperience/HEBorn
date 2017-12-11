module Game.Meta.Type.MotherboardTest exposing (all)

import Expect
import Dict
import Gen.Inventory as Gen
import Gen.Hardware as Gen
import Fuzz exposing (unit, tuple, tuple3, tuple4)
import Test exposing (Test, describe)
import TestUtils exposing (fuzz, batch)
import Game.Meta.Types.Components.Motherboard exposing (..)
import Game.Meta.Types.Components.Motherboard.Diff exposing (..)


all : Test
all =
    describe "motherboard"
        [ operationsTests
        ]


operationsTests : Test
operationsTests =
    describe "operation tests"
        [ describe "diff"
            diffTests
        ]



--------------------------------------------------------------------------------
-- Diff Motherboard
--------------------------------------------------------------------------------


diffTests : List Test
diffTests =
    [ describe "diff with empty motherboards"
        emptyDiffTests
    , describe "diff with linked motherboards"
        linkedDiffTests
    ]


emptyDiffTests : List Test
emptyDiffTests =
    [ fuzz (tuple ( Gen.motherboard, Gen.emptyMotherboard ))
        "unlink everything from motherboard"
      <|
        \( filled, empty ) ->
            let
                ( linked, unlinked ) =
                    diff empty filled

                unlinkLength =
                    (countComponents filled) + countNCs filled
            in
                batch
                    -- nothing should be linked
                    [ Expect.equal True (List.isEmpty linked)

                    -- everything should be unlinked
                    , Expect.equal unlinkLength (List.length unlinked)
                    ]
    , fuzz (tuple ( Gen.motherboard, Gen.emptyMotherboard ))
        "link to empty motherboard"
      <|
        \( filled, empty ) ->
            let
                ( linked, unlinked ) =
                    diff filled empty

                linkLength =
                    (countComponents filled) + (countNCs filled)
            in
                batch
                    -- nothing should be unlinked
                    [ Expect.equal True (List.isEmpty unlinked)

                    -- everything should be linked
                    , Expect.equal linkLength (List.length linked)
                    ]
    ]


linkedDiffTests : List Test
linkedDiffTests =
    [ fuzz (tuple ( Gen.motherboard, Gen.shiftMotherboard ))
        "change component slots"
      <|
        \( normal, shifted ) ->
            let
                ( linked, unlinked ) =
                    diff shifted normal

                shiftLength =
                    countComponents shifted
            in
                batch
                    -- no unlinks because nothing component was freed
                    [ Expect.equal True (List.isEmpty unlinked)

                    -- changed slots are new link events
                    , Expect.equal shiftLength (List.length linked)
                    ]
    , fuzz (tuple ( Gen.motherboard, Gen.fullMotherboard ))
        "from non-empty motherboard to full motherboard"
      <|
        \( half, full ) ->
            let
                ( linked, unlinked ) =
                    diff full half

                fullComponents =
                    (countComponents full) + (countNCs full)

                halfComponents =
                    (countComponents half) + (countNCs half)

                diffComponents =
                    fullComponents - halfComponents
            in
                batch
                    -- nothing should be unlinked
                    [ Expect.equal True (List.isEmpty unlinked)

                    -- shows only what was linked
                    , Expect.equal diffComponents (List.length linked)
                    ]
    , fuzz (tuple ( Gen.motherboard, Gen.fullMotherboard ))
        "from full motherboard to an non-empty motherboard"
      <|
        \( half, full ) ->
            let
                ( linked, unlinked ) =
                    diff half full

                fullComponents =
                    (countComponents full) + (countNCs full)

                halfComponents =
                    (countComponents half) + (countNCs half)

                diffComponents =
                    fullComponents - halfComponents
            in
                batch
                    -- nothing should be linked
                    [ Expect.equal True (List.isEmpty linked)

                    -- shows only what was unlinked
                    , Expect.equal diffComponents (List.length unlinked)
                    ]
    ]



-- helpers


countComponents : Motherboard -> Int
countComponents =
    getSlots
        >> Dict.toList
        >> List.filterMap (Tuple.second >> getSlotComponent)
        >> List.length


countNCs : Motherboard -> Int
countNCs =
    getNCs >> Dict.size
