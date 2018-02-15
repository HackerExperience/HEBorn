module Decoders.Dock exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , andThen
        , succeed
        , fail
        , list
        , string
        )
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Account.Dock.Models exposing (..)
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


dock : Decoder Model
dock =
    string
        |> andThen app
        |> list


app : String -> Decoder DesktopApp
app str =
    case str of
        "browser" ->
            succeed DesktopApp.Browser

        "explorer" ->
            succeed DesktopApp.Explorer

        "logvw" ->
            succeed DesktopApp.LogViewer

        "taskmngr" ->
            succeed DesktopApp.TaskManager

        "db" ->
            succeed DesktopApp.DBAdmin

        "connmngr" ->
            succeed DesktopApp.ConnManager

        "bouncemngr" ->
            succeed DesktopApp.BounceManager

        "finances" ->
            succeed DesktopApp.Finance

        "hebamp" ->
            succeed DesktopApp.Music

        "ctrlpnl" ->
            succeed DesktopApp.CtrlPanel

        "srvsgrs" ->
            succeed DesktopApp.ServersGears

        "lanvw" ->
            succeed DesktopApp.LanViewer

        "emails" ->
            succeed DesktopApp.Email

        error ->
            fail <| commonError "app_type" error
