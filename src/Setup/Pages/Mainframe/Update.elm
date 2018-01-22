module Setup.Pages.Mainframe.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Utils.Maybe as Maybe
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)
import Setup.Requests.Check as Check
import Game.Account.Models as Account


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Mainframe str ->
            onMainframe str model

        Validate ->
            onValidate config model

        Checked True ->
            Update.fromModel <| setOkay model

        Checked False ->
            Update.fromModel model


onMainframe : String -> Model -> UpdateResponse msg
onMainframe str model =
    Update.fromModel <| setMainframeName str model


onValidate : Config msg -> Model -> UpdateResponse msg
onValidate ({ toMsg, mainframe } as config) model =
    let
        hostname =
            getHostname model

        cmd =
            case hostname of
                Just name ->
                    Check.serverName (Checked >> toMsg)
                        name
                        mainframe
                        config

                Nothing ->
                    Cmd.none
    in
        ( model, cmd, Dispatch.none )
