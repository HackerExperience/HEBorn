module Apps.Browser.Widgets.PublicFiles.View exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))
import Apps.Browser.Widgets.PublicFiles.Model exposing (..)


type alias Config msg =
    { source : NIP
    , onCommonAction : CommonActions -> msg
    }


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


publicFiles : Config msg -> Model -> Html msg
publicFiles config model =
    ul [] <|
        List.map (file config) model


file : Config msg -> Filesystem.FileEntry -> Html msg
file config fileEntry =
    fileEntry
        |> Filesystem.toFile
        |> Filesystem.getType
        |> fileModules
        |> List.map
            (\( name, ver ) ->
                name
                    ++ " -> VER: "
                    ++ toString ver
                    |> text
                    |> List.singleton
                    |> li []
            )
        |> ul []
        |> List.singleton
        |> (::)
            (span []
                [ text <| Filesystem.getName <| Filesystem.toFile fileEntry ]
            )
        |> li
            [ fileEntry
                |> PublicDownload config.source
                |> config.onCommonAction
                |> onClick
            ]


fileModules : Filesystem.Type -> List ( String, Filesystem.Version )
fileModules filesystem =
    List.map (\( a, b ) -> ( a, Filesystem.getModuleVersion b )) <|
        case filesystem of
            Filesystem.Cracker { bruteForce, overFlow } ->
                [ ( "Bruteforce", bruteForce )
                , ( "Overflow", overFlow )
                ]

            Filesystem.Firewall { active, passive } ->
                [ ( "Active", active )
                , ( "Passive", passive )
                ]

            Filesystem.Exploit { ftp, ssh } ->
                [ ( "FTP", ftp )
                , ( "SSH", ssh )
                ]

            Filesystem.Hasher { password } ->
                [ ( "Password", password ) ]

            Filesystem.LogForger { create, edit } ->
                [ ( "Create", create )
                , ( "Edit", edit )
                ]

            Filesystem.LogRecover { recover } ->
                [ ( "Recover", recover ) ]

            Filesystem.Encryptor { file, log, connection, process } ->
                [ ( "File", file )
                , ( "Log", log )
                , ( "Connections", connection )
                , ( "Process", process )
                ]

            Filesystem.Decryptor { file, log, connection, process } ->
                [ ( "File", file )
                , ( "Log", log )
                , ( "Connections", connection )
                , ( "Process", process )
                ]

            Filesystem.AnyMap { geo, net } ->
                [ ( "Geo", geo )
                , ( "Net", net )
                ]

            _ ->
                []
