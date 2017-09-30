module Game.Storyline.Requests.Bootstrap exposing (..)

import Json.Decode exposing (Decoder)
import Events.Storyline.Emails as Emails
import Events.Storyline.Missions as Missions
import Game.Storyline.Emails.Models as Emails
import Game.Storyline.Missions.Models as Missions


emailsDecoder : Decoder Emails.Model
emailsDecoder =
    Emails.decoder


missionsDecoder : Decoder Missions.Model
missionsDecoder =
    Missions.decoder
