module OS.Subscriptions exposing (subscriptions)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import Game.Data as GameData
import OS.Menu.Models as Menu
import OS.Menu.Subscriptions as Menu
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


{-| TODO: change signature to GameData.Data -> Model -> Sub Msg
-}
subscriptions : GameData.Data -> Model -> Sub Msg
subscriptions data model =
    let
        menuSub =
            menu model.menu

        sessionSub =
            session data model.session
    in
        Sub.batch
            [ menuSub
            , sessionSub
            ]



-- internals


menu : Menu.Model -> Sub Msg
menu model =
    model
        |> Menu.subscriptions
        |> Sub.map MenuMsg


session : GameData.Data -> SessionManager.Model -> Sub Msg
session data model =
    model
        |> SessionManager.subscriptions data
        |> Sub.map SessionManagerMsg
