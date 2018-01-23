module Setup.Pages.Mainframe.Update exposing (update)

import Utils.Maybe as Maybe
import Utils.React as React exposing (React)
import Game.Account.Models as Account
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)
import Setup.Requests.Check as Check


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Mainframe str ->
            onMainframe str model

        Validate ->
            onValidate config model

        Checked True ->
            ( setOkay model, React.none )

        Checked False ->
            ( model, React.none )


onMainframe : String -> Model -> UpdateResponse msg
onMainframe str model =
    ( setMainframeName str model, React.none )


onValidate : Config msg -> Model -> UpdateResponse msg
onValidate ({ toMsg, mainframe } as config) model =
    let
        cmd =
            case Maybe.uncurry (getHostname model) mainframe of
                Just ( name, mainframe ) ->
                    Check.serverName (Checked >> toMsg)
                        name
                        mainframe
                        config

                Nothing ->
                    Cmd.none
    in
        ( model, React.cmd cmd )
