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
import Apps.Apps as Apps


dock : Decoder Model
dock =
    string
        |> andThen app
        |> list


app : String -> Decoder Apps.App
app str =
    case str of
        "browser" ->
            succeed Apps.BrowserApp

        "explorer" ->
            succeed Apps.ExplorerApp

        "logvw" ->
            succeed Apps.LogViewerApp

        "taskmngr" ->
            succeed Apps.TaskManagerApp

        "db" ->
            succeed Apps.DatabaseApp

        "connmngr" ->
            succeed Apps.ConnManagerApp

        "bouncemngr" ->
            succeed Apps.BounceManagerApp

        "finances" ->
            succeed Apps.FinanceApp

        "hebamp" ->
            succeed Apps.MusicApp

        "ctrlpnl" ->
            succeed Apps.CtrlPanelApp

        "srvsgrs" ->
            succeed Apps.ServersGearsApp

        "lanvw" ->
            succeed Apps.LanViewerApp

        "emails" ->
            succeed Apps.EmailApp

        error ->
            fail <| commonError "app_type" error
