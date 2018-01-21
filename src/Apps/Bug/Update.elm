module Apps.Bug.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Error as Error
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Account as Account
import Game.Data as Game
import Native.Panic
import Apps.Bug.Config exposing (..)
import Apps.Bug.Models exposing (Model)
import Apps.Bug.Messages as Hackerbug exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Hackerbug.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        -- -- Context
        DummyToast ->
            onDummyToast model

        PoliteCrash ->
            onPoliteCrash model

        UnpoliteCrash ->
            onUnpoliteCrash model


onDummyToast : Model -> UpdateResponse msg
onDummyToast model =
    ( model
    , React.none
      -- REVIEW: Port me later
      --, Notifications.Simple "Hi" "Hello"
      --    |> Notifications.Toast Nothing
      --    |> Dispatch.notifications
    )


onPoliteCrash : Model -> UpdateResponse msg
onPoliteCrash model =
    ( model
    , React.none
      --, "This is a polite crash."
      --    |> Error.fakeTest
      --    |> Account.LogoutAndCrash
      --    |> Dispatch.account
    )


onUnpoliteCrash : Model -> UpdateResponse msg
onUnpoliteCrash model =
    ( model, React.none )



--"This is an unpolite crash."
--    |> Error.fakeTest
--    |> uncurry Native.Panic.crash
