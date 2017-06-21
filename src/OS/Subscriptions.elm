module OS.Subscriptions exposing (subscriptions)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import Game.Models as Game
import OS.Menu.Models as Menu
import OS.Menu.Subscriptions as Menu
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


{-| TODO: change signature to Game.Model -> Model -> Sub Msg
-}
subscriptions : Game.Model -> Model -> Sub Msg
subscriptions game model =
    let
        menuSub =
            menu model.menu

        sessionSub =
            session game model.session
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


session : Game.Model -> SessionManager.Model -> Sub Msg
session game model =
    model
        |> SessionManager.subscriptions game
        |> Sub.map SessionManagerMsg
