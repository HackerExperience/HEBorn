module Events.Account.Handlers.VirusCollected exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Database exposing (virusCollected)
import Game.Account.Bounces.Shared exposing (ID)
import Game.Account.Finances.Models exposing (AtmId, AccountNumber)
import Game.Meta.Types.Network exposing (NIP)
import Events.Shared exposing (Handler)


type alias Data =
    -- AtmId, AccountNumber, Value received, file_id, server_nip
    ( AtmId, AccountNumber, Int, ID, NIP )


handler : Handler Data msg
handler toMsg =
    decodeValue virusCollected >> Result.map toMsg
