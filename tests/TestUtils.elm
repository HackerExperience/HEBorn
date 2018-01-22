module TestUtils exposing (..)

import Expect exposing (Expectation)
import Utils.React as React exposing (React)
import Driver.Websocket.Channels as Ws
import Core.Config as Core
import Core.Messages as Core
import Game.Messages as Game
import Game.Config as Game
import Game.Models as Game
import Game.Update as Game
import Json.Decode as Decode
import Events.Handler as Events
import Test exposing (..)
import Config


once param =
    fuzzWith { runs = 1 } param


fuzz param =
    fuzzWith { runs = Config.baseFuzzRuns } param


batch : List Expectation -> Expectation
batch =
    List.map always >> flip Expect.all ()


applyEvent : String -> String -> Ws.Channel -> Game.Model -> Game.Model
applyEvent name data channel model =
    let
        result =
            ( name, toValue data )
                |> Ok
                |> Events.handler Core.eventsConfig channel
                |> Result.map React.msg
    in
        case result of
            Ok msg ->
                gameDispatcher model msg

            Err error ->
                always model <| Debug.log (Events.report error) ""


toValue : String -> Decode.Value
toValue =
    Decode.decodeString Decode.value >> fromOk "invalid json"


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


gameDispatcher :
    Game.Model
    -> React Core.Msg
    -> Game.Model
gameDispatcher model react =
    let
        msgs =
            react
                |> React.split
                |> Tuple.first
                |> Maybe.map Core.unroll
                |> Maybe.withDefault []

        ( model_, react_ ) =
            List.foldl gameReducer ( model, React.none ) msgs
    in
        case msgs of
            [] ->
                model

            list ->
                gameDispatcher model_ react_


gameReducer :
    Core.Msg
    -> ( Game.Model, React Core.Msg )
    -> ( Game.Model, React Core.Msg )
gameReducer msg ( model, react ) =
    case msg of
        Core.GameMsg msg ->
            let
                ( model_, react_ ) =
                    Game.update Core.gameConfig msg model
            in
                ( model_
                , React.batch Core.BatchMsg [ react, react_ ]
                )

        _ ->
            ( model, react )


hint : String -> String
hint str =
    if str == "" then
        ""
    else
        " (" ++ str ++ ")"



-- legacy helpers


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
        ( model1, cmd ) =
            Game.update Core.gameConfig msg0 model0
    in
        gameDispatcher model1 cmd
