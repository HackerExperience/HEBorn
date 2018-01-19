module Apps.Bug.Update exposing (update)

import Core.Error as Error
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Game.Data as Game
import Native.Panic
import Apps.Bug.Models exposing (Model)
import Apps.Bug.Messages as Hackerbug exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd Hackerbug.Msg, Dispatch )


update :
    Game.Data
    -> Hackerbug.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        DummyToast ->
            onDummyToast model

        PoliteCrash ->
            onPoliteCrash model

        UnpoliteCrash ->
            onUnpoliteCrash model


onDummyToast : Model -> UpdateResponse
onDummyToast model =
    ( model
    , Cmd.none
    , Dispatch.none
      -- REVIEW: Port me later
      --, Notifications.Simple "Hi" "Hello"
      --    |> Notifications.Toast Nothing
      --    |> Dispatch.notifications
    )


onPoliteCrash : Model -> UpdateResponse
onPoliteCrash model =
    ( model
    , Cmd.none
    , "This is a polite crash."
        |> Error.fakeTest
        |> Account.LogoutAndCrash
        |> Dispatch.account
    )


onUnpoliteCrash : Model -> UpdateResponse
onUnpoliteCrash model =
    "This is an unpolite crash."
        |> Error.fakeTest
        |> uncurry Native.Panic.crash
