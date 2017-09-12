module TestUtils exposing (..)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Messages as Core
import Game.Messages as Game
import Game.Models as Game
import Game.Update as Game
import Json.Decode as Decode
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


updateGame : Game.Msg -> Game.Model -> Game.Model
updateGame msg0 model0 =
    let
        ( model1, _, dispatch ) =
            Game.update msg0 model0

        keepGameMsg msg =
            case msg of
                Core.GameMsg msg ->
                    Just msg

                _ ->
                    Nothing

        msgs =
            dispatch
                |> Dispatch.toList
                |> List.filterMap keepGameMsg

        reduce msg model =
            updateGame msg model
    in
        List.foldl reduce model1 msgs


fromJust : Maybe a -> a
fromJust m =
    case m of
        Just a ->
            a

        Nothing ->
            Debug.crash "fromJust called with Nothing"


fromOk : Result b a -> a
fromOk m =
    case m of
        Ok a ->
            a

        Err _ ->
            Debug.crash "fromOk called with Err"


toValue : String -> Decode.Value
toValue =
    Decode.decodeString Decode.value >> fromOk
