module Game.Storyline.Requests.Bootstrap exposing (..)

import Json.Decode exposing (Decoder)
import Events.Storyline.Missions as Missions
import Events.Storyline.Emails as Emails
import Game.Storyline.Missions.Models as Missions
import Game.Storyline.Emails.Models as Emails


-- TODO: Clone decoder functions to here


emailsDecoder : Decoder Emails.Model
emailsDecoder =
    Emails.decoder


missionsDecoder : Decoder Missions.Model
missionsDecoder =
    Missions.decoder
