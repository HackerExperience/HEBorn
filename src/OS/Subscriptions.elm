module OS.Subscriptions exposing (subscriptions)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import Game.Models exposing (GameModel)
import OS.Menu.Models as Menu
import OS.Menu.Subscriptions as Menu
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


{-| TODO: change signature to GameModel -> Model -> Sub Msg
-}
subscriptions : GameModel -> Model -> Sub OSMsg
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


menu : Menu.Model -> Sub OSMsg
menu model =
    model
        |> Menu.subscriptions
        |> Sub.map ContextMenuMsg


session : GameModel -> SessionManager.Model -> Sub OSMsg
session game model =
    model
        |> SessionManager.subscriptions game
        |> Sub.map SessionManagerMsg
