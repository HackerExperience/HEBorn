module TestUtils exposing (..)

import Expect exposing (Expectation)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.React as React exposing (React)
import Core.Subscribers as Subscribers
import Core.Config as Core
import Core.Messages as Core
import Game.Messages as Game
import Game.Config as Game
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
            Game.update Core.gameConfig msg0 model0
    in
        gameDispatcher model1 cmd dispatch


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


gameDispatcher :
    Game.Model
    -> React Core.Msg
    -> Dispatch
    -> Game.Model
gameDispatcher model react dispatch =
    let
        msgs =
            react
                |> React.split
                |> Tuple.first
                |> Maybe.map Core.unroll
                |> Maybe.withDefault []

        msgs_ =
            msgs ++ Subscribers.dispatch dispatch

        ( model_, react_, dispatch_ ) =
            List.foldl gameReducer ( model, React.none, Dispatch.none ) msgs_
    in
        case msgs_ of
            [] ->
                model

            list ->
                gameDispatcher model_ react_ dispatch_


gameReducer :
    Core.Msg
    -> ( Game.Model, React Core.Msg, Dispatch )
    -> ( Game.Model, React Core.Msg, Dispatch )
gameReducer msg ( model, react, dispatch ) =
    case msg of
        Core.GameMsg msg ->
            let
                ( model_, react_, dispatch_ ) =
                    Game.update Core.gameConfig msg model
            in
                ( model_
                , React.batch Core.MultiMsg [ react, react_ ]
                , Dispatch.batch [ dispatch, dispatch_ ]
                )

        _ ->
            ( model, react, dispatch )
