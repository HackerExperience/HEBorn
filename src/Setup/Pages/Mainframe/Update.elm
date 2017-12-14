module Setup.Pages.Mainframe.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Update as Update
import Utils.Maybe as Maybe
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)
import Setup.Requests.Check as Check
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

        Checked True ->
            Update.fromModel <| setOkay model

        Checked False ->
            Update.fromModel model


onMainframe : String -> Model -> UpdateResponse msg
onMainframe str model =
    Update.fromModel <| setMainframeName str model


onValidate : Config msg -> Game.Model -> Model -> UpdateResponse msg
onValidate { toMsg } game model =
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
                    Check.serverName (Checked >> toMsg) name cid game

                Nothing ->
                    Cmd.none
    in
        ( model, cmd, Dispatch.none )
