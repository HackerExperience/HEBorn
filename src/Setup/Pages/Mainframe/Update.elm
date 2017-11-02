module Setup.Pages.Mainframe.Update exposing (update)

import Json.Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Update as Update
import Utils.Maybe as Maybe
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Requests exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)
import Game.Servers.Settings.Check as Check
import Game.Servers.Settings.Set as Set
import Game.Servers.Settings.Types exposing (..)
import Game.Account.Models as Account


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Game.Model -> Msg -> Model -> UpdateResponse msg
update config game msg model =
    case msg of
        Mainframe str ->
            onMainframe str model

        Validate ->
            onValidate config game model

        Request data ->
            updateRequest config game (receive data) model


onMainframe : String -> Model -> UpdateResponse msg
onMainframe str model =
    Update.fromModel <| setMainframeName str model


onValidate : Config msg -> Game.Model -> Model -> UpdateResponse msg
onValidate config game model =
    let
        mainframe =
            game
                |> Game.getAccount
                |> Account.getMainframe

        hostname =
            getHostname model

        cmd =
            case Maybe.uncurry mainframe hostname of
                Just ( cid, name ) ->
                    checkRequest config (Name name) cid game

                Nothing ->
                    Cmd.none
    in
        ( model, cmd, Dispatch.none )



-- request handlers


updateRequest :
    Config msg
    -> Game.Model
    -> Maybe Response
    -> Model
    -> UpdateResponse msg
updateRequest config game mResponse model =
    case mResponse of
        Just (Check (Check.Valid _)) ->
            onCheckValid config game model

        Just (Check (Check.Invalid reason)) ->
            Update.fromModel model

        Just (Set (Set.Valid _)) ->
            Update.fromModel <| setOkay model

        Just (Set (Set.Invalid _)) ->
            Update.fromModel model

        Nothing ->
            Update.fromModel model


onCheckValid : Config msg -> Game.Model -> Model -> UpdateResponse msg
onCheckValid config game model =
    let
        mainframe =
            game
                |> Game.getAccount
                |> Account.getMainframe

        hostname =
            getHostname model

        cmd =
            case Maybe.uncurry mainframe hostname of
                Just ( cid, name ) ->
                    setRequest config (Name name) cid game

                Nothing ->
                    Cmd.none
    in
        ( model, cmd, Dispatch.none )
