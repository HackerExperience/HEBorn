module Events.Account.Dock exposing (Event(..), handler, decoder)

import Json.Decode
    exposing
        ( Decoder
        , succeed
        , fail
        , decodeValue
        , andThen
        , list
        , string
        )
import Utils.Events exposing (Handler, commonError)
import Game.Account.Dock.Models as Dock
import Apps.Apps as Apps


type Event
    = Changed


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing



-- internals


onChanged : Handler Event
onChanged json =
    Just Changed


decoder : Decoder Dock.Model
decoder =
    list app


app : Decoder Apps.App
app =
    let
        guesser str =
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
    in
        string
            |> andThen guesser
