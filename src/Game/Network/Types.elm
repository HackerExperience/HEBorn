module Game.Network.Types exposing (..)


type alias IP =
    String


type alias ID =
    String


type alias NIP =
    ( ID, IP )


type alias StringifiedNIP =
    String


toString : NIP -> StringifiedNIP
toString ( id, ip ) =
    id ++ "," ++ ip


fromString : StringifiedNIP -> NIP
fromString str =
    case String.split "," str of
        [ id, ip ] ->
            ( id, ip )

        _ ->
            ( "::", "" )
