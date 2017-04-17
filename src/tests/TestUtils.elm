module TestUtils exposing (..)

import Test exposing (..)
import Config


once param =
    fuzzWith { runs = 1 } param


fuzz param =
    fuzzWith { runs = Config.baseFuzzRuns } param


ensureDifferentSeed : ( Int, Int ) -> ( Int, Int )
ensureDifferentSeed seed =
    let
        ( seed1, seed2 ) =
            seed

        seed_ =
            if seed1 == seed2 then
                ( seed1, seed1 + seed2 + 1 )
            else if seed1 == (seed2 * (-1)) then
                -- On (x, -x) seeds we've been having trouble because of our
                -- Gen.Utils generators
                ( seed1, seed2 + 1 )
            else
                seed
    in
        seed_
