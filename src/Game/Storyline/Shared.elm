module Game.Storyline.Shared exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)


type alias ContactId =
    String


type alias PastEmails =
    Dict Time PastEmail


type PastEmail
    = FromContact Reply
    | FromPlayer Reply


type Reply
    = AboutThat
    | BackThanks
    | DlaydMuch1
    | DownloadCracker1 SomeIP
    | Downloaded
    | HellYeah
    | NastyVirus1
    | NastyVirus2
    | NothingNow
    | Punks1
    | Punks2
    | Punks3 SomeIP
    | WatchIADoing
    | Welcome
    | YeahRight


type alias SomeIP =
    String


type Objective
    = DownloadCracker
    | VirusInquiry
    | CleanUp
    | Grandmadness


type Step
    = Tutorial_SetupPC
    | Tutorial_DownloadCracker
    | Tutorial_NastyVirus


type Quest
    = Tutorial


type alias About =
    { nick : String
    , picture : String
    }
