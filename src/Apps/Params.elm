module Apps.Params exposing (..)

import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Apps.BounceManager.Shared as BounceManager
import Apps.Browser.Shared as Browser
import Apps.FloatingHeads.Models as FloatingHeads
import Apps.Hebamp.Shared as Hebamp


type AppParams
    = BounceManager BounceManager.Params
    | Browser Browser.Params
    | FloatingHeads FloatingHeads.Params
    | Hebamp Hebamp.Params


toAppType : AppParams -> DesktopApp
toAppType params =
    case params of
        BounceManager _ ->
            DesktopApp.BounceManager

        Browser _ ->
            DesktopApp.Browser

        FloatingHeads _ ->
            DesktopApp.FloatingHeads

        Hebamp _ ->
            DesktopApp.Hebamp


castBounceManager : AppParams -> Maybe BounceManager.Params
castBounceManager params =
    case params of
        BounceManager params ->
            Just params

        _ ->
            Nothing


castBrowser : AppParams -> Maybe Browser.Params
castBrowser params =
    case params of
        Browser params ->
            Just params

        _ ->
            Nothing


castFloatingHeads : AppParams -> Maybe FloatingHeads.Params
castFloatingHeads params =
    case params of
        FloatingHeads params ->
            Just params

        _ ->
            Nothing


castHebamp : AppParams -> Maybe Hebamp.Params
castHebamp params =
    case params of
        Hebamp params ->
            Just params

        _ ->
            Nothing
