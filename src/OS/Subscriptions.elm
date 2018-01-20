module OS.Subscriptions exposing (subscriptions)

import OS.Config exposing (..)
import OS.Models exposing (..)
import OS.Messages exposing (..)
import Game.Data as Game
import OS.Menu.Models as Menu
import OS.Menu.Subscriptions as Menu
import OS.SessionManager.Models as SessionManager
import OS.SessionManager.Subscriptions as SessionManager


subscriptions : Config msg -> Game.Data -> Model -> Sub msg
subscriptions config data model =
    let
        menuSub =
            menu config model.menu

        sessionSub =
            session config data model.session
    in
        Sub.batch
            [ menuSub
            , sessionSub
            ]



-- internals


menu : Config msg -> Menu.Model -> Sub msg
menu config model =
    model
        |> Menu.subscriptions
        |> Sub.map (MenuMsg >> config.toMsg)


session : Config msg -> Game.Data -> SessionManager.Model -> Sub msg
session config data model =
    let
        config_ =
            smConfig config
    in
        model
            |> SessionManager.subscriptions config_ data
