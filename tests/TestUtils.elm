module TestUtils exposing (..)

import Expect exposing (Expectation)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Subscribers as Subscribers
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


batch : List Expectation -> Expectation
batch =
    List.map always >> flip Expect.all ()


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
        ( model1, cmd, dispatch ) =
            Game.update msg0 model0

        ( model2, _ ) =
            gameDispatcher model1 cmd dispatch
    in
        model2


fromJust : String -> Maybe a -> a
fromJust tip m =
    case m of
        Just a ->
            a

        Nothing ->
            Debug.crash ("fromJust called with Nothing" ++ hint tip)


fromOk : String -> Result b a -> a
fromOk tip m =
    case m of
        Ok a ->
            a

        Err _ ->
            Debug.crash ("fromOk called with Err" ++ hint tip)


toValue : String -> Decode.Value
toValue =
    Decode.decodeString Decode.value >> fromOk "invalid json"


hint : String -> String
hint str =
    if str == "" then
        ""
    else
        " (" ++ str ++ ")"



-- REPLICANTS FROM CORE.UPDATE MODIFIED TO USE GAME.MODEL


gameDispatcher : Game.Model -> Cmd Game.Msg -> Dispatch -> ( Game.Model, Cmd Game.Msg )
gameDispatcher model cmd dispatch =
    dispatch
        |> Subscribers.dispatch
        |> List.foldl gameReducer ( model, cmd )


gameReducer : Core.Msg -> ( Game.Model, Cmd Game.Msg ) -> ( Game.Model, Cmd Game.Msg )
gameReducer msg ( model, cmd ) =
    let
        ( model_, cmd_, _ ) =
            case msg of
                Core.GameMsg msg ->
                    Game.update msg model

                _ ->
                    ( model, cmd, Dispatch.none )
    in
        ( model_, Cmd.batch [ cmd, cmd_ ] )
