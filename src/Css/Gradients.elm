module Css.Gradients exposing (..)

import Css exposing (Style, AngleOrDirection, backgroundImage, linearGradient2, stop, stop2, hex, pct)


-- AUTO Generated from: https://raw.githubusercontent.com/ghosh/uiGradients/master/gradients.json
-- replaced "name": "([\w ]*) with "name": "\E$1
-- replaced "(\w*) (\w) with ""$1\U$2
-- used regex: /^\s*{\s*"name": "([\' \w0-9]*)",\s*"colors": \["#([a-f0-9]*)", "#([a-f0-9]*)", "#([a-f0-9]*)"\]\s*},?/g
-- and with fewer color samples


gradient2 : String -> String -> AngleOrDirection c -> Style
gradient2 c1 c2 dir =
    backgroundImage <|
        linearGradient2 dir (stop <| hex c1) (stop <| hex c2) []


gradient3 : String -> String -> String -> AngleOrDirection c -> Style
gradient3 c1 c2 c3 dir =
    backgroundImage <|
        linearGradient2 dir (stop2 (hex c1) (pct 0)) (stop2 (hex c2) (pct 0)) [ (stop <| hex c3) ]


sel : AngleOrDirection c -> Style
sel =
    gradient2 "00467F" "A5CC82"


dimigo : AngleOrDirection c -> Style
dimigo =
    gradient2 "ec008c" "fc6767"


purpleLove : AngleOrDirection c -> Style
purpleLove =
    gradient2 "cc2b5e" "753a88"


sexyBlue : AngleOrDirection c -> Style
sexyBlue =
    gradient2 "2193b0" "6dd5ed"


blooker20 : AngleOrDirection c -> Style
blooker20 =
    gradient2 "e65c00" "F9D423"


seaBlue : AngleOrDirection c -> Style
seaBlue =
    gradient2 "2b5876" "4e4376"


nimvelo : AngleOrDirection c -> Style
nimvelo =
    gradient2 "314755" "26a0da"


hazel : AngleOrDirection c -> Style
hazel =
    gradient3 "77A1D3" "79CBCA" "E684AE"


noonToDusk : AngleOrDirection c -> Style
noonToDusk =
    gradient2 "ff6e7f" "bfe9ff"


youtube : AngleOrDirection c -> Style
youtube =
    gradient2 "e52d27" "b31217"


rown : AngleOrDirection c -> Style
rown =
    gradient2 "603813" "b29f94"


harmonicEnergy : AngleOrDirection c -> Style
harmonicEnergy =
    gradient2 "16A085" "F4D03F"


playingWithReds : AngleOrDirection c -> Style
playingWithReds =
    gradient2 "D31027" "EA384D"


sunnyDays : AngleOrDirection c -> Style
sunnyDays =
    gradient2 "EDE574" "E1F5C4"


greenBeach : AngleOrDirection c -> Style
greenBeach =
    gradient2 "02AAB0" "00CDAC"


intuitivePurple : AngleOrDirection c -> Style
intuitivePurple =
    gradient2 "DA22FF" "9733EE"


emeraldWater : AngleOrDirection c -> Style
emeraldWater =
    gradient2 "348F50" "56B4D3"


lemonTwist : AngleOrDirection c -> Style
lemonTwist =
    gradient2 "3CA55C" "B5AC49"


monteCarlo : AngleOrDirection c -> Style
monteCarlo =
    gradient3 "CC95C0" "DBD4B4" "7AA1D2"


horizon : AngleOrDirection c -> Style
horizon =
    gradient2 "003973" "E5E5BE"


roseWater : AngleOrDirection c -> Style
roseWater =
    gradient2 "E55D87" "5FC3E4"


frozen : AngleOrDirection c -> Style
frozen =
    gradient2 "403B4A" "E7E9BB"


mangoPulp : AngleOrDirection c -> Style
mangoPulp =
    gradient2 "F09819" "EDDE5D"


bloodyMary : AngleOrDirection c -> Style
bloodyMary =
    gradient2 "FF512F" "DD2476"


aubergine : AngleOrDirection c -> Style
aubergine =
    gradient2 "AA076B" "61045F"


aquaMarine : AngleOrDirection c -> Style
aquaMarine =
    gradient2 "1A2980" "26D0CE"


sunrise : AngleOrDirection c -> Style
sunrise =
    gradient2 "FF512F" "F09819"


purpleParadise : AngleOrDirection c -> Style
purpleParadise =
    gradient2 "1D2B64" "F8CDDA"


stripe : AngleOrDirection c -> Style
stripe =
    gradient3 "1FA2FF" "12D8FA" "A6FFCB"


seaWeed : AngleOrDirection c -> Style
seaWeed =
    gradient2 "4CB8C4" "3CD3AD"


pinky : AngleOrDirection c -> Style
pinky =
    gradient2 "DD5E89" "F7BB97"


cherry : AngleOrDirection c -> Style
cherry =
    gradient2 "EB3349" "F45C43"


mojito : AngleOrDirection c -> Style
mojito =
    gradient2 "1D976C" "93F9B9"


juicyOrange : AngleOrDirection c -> Style
juicyOrange =
    gradient2 "FF8008" "FFC837"


mirage : AngleOrDirection c -> Style
mirage =
    gradient2 "16222A" "3A6073"


steelGray : AngleOrDirection c -> Style
steelGray =
    gradient2 "1F1C2C" "928DAB"


kashmir : AngleOrDirection c -> Style
kashmir =
    gradient2 "614385" "516395"


electricViolet : AngleOrDirection c -> Style
electricViolet =
    gradient2 "4776E6" "8E54E9"


veniceBlue : AngleOrDirection c -> Style
veniceBlue =
    gradient2 "085078" "85D8CE"


boraBora : AngleOrDirection c -> Style
boraBora =
    gradient2 "2BC0E4" "EAECC6"


moss : AngleOrDirection c -> Style
moss =
    gradient2 "134E5E" "71B280"


shroomHaze : AngleOrDirection c -> Style
shroomHaze =
    gradient2 "5C258D" "4389A2"


mystic : AngleOrDirection c -> Style
mystic =
    gradient2 "757F9A" "D7DDE8"


midnightCity : AngleOrDirection c -> Style
midnightCity =
    gradient2 "232526" "414345"


seaBlizz : AngleOrDirection c -> Style
seaBlizz =
    gradient2 "1CD8D2" "93EDC7"


opa : AngleOrDirection c -> Style
opa =
    gradient2 "3D7EAA" "FFE47A"


titanium : AngleOrDirection c -> Style
titanium =
    gradient2 "283048" "859398"


mantle : AngleOrDirection c -> Style
mantle =
    gradient2 "24C6DC" "514A9D"


dracula : AngleOrDirection c -> Style
dracula =
    gradient2 "DC2424" "4A569D"


peach : AngleOrDirection c -> Style
peach =
    gradient2 "ED4264" "FFEDBC"


moonrise : AngleOrDirection c -> Style
moonrise =
    gradient2 "DAE2F8" "D6A4A4"


clouds : AngleOrDirection c -> Style
clouds =
    gradient2 "ECE9E6" "FFFFFF"


stellar : AngleOrDirection c -> Style
stellar =
    gradient2 "7474BF" "348AC7"


bourbon : AngleOrDirection c -> Style
bourbon =
    gradient2 "EC6F66" "F3A183"


calmDarya : AngleOrDirection c -> Style
calmDarya =
    gradient2 "5f2c82" "49a09d"


influenza : AngleOrDirection c -> Style
influenza =
    gradient2 "C04848" "480048"


shrimpy : AngleOrDirection c -> Style
shrimpy =
    gradient2 "e43a15" "e65245"


army : AngleOrDirection c -> Style
army =
    gradient2 "414d0b" "727a17"


miaka : AngleOrDirection c -> Style
miaka =
    gradient2 "FC354C" "0ABFBC"


pinotNoir : AngleOrDirection c -> Style
pinotNoir =
    gradient2 "4b6cb7" "182848"


dayTripper : AngleOrDirection c -> Style
dayTripper =
    gradient2 "f857a6" "ff5858"


namn : AngleOrDirection c -> Style
namn =
    gradient2 "a73737" "7a2828"


blurryBeach : AngleOrDirection c -> Style
blurryBeach =
    gradient2 "d53369" "cbad6d"


vasily : AngleOrDirection c -> Style
vasily =
    gradient2 "e9d362" "333333"


aLostMemory : AngleOrDirection c -> Style
aLostMemory =
    gradient2 "DE6262" "FFB88C"


petrichor : AngleOrDirection c -> Style
petrichor =
    gradient2 "666600" "999966"


jonquil : AngleOrDirection c -> Style
jonquil =
    gradient2 "FFEEEE" "DDEFBB"


siriusTamed : AngleOrDirection c -> Style
siriusTamed =
    gradient2 "EFEFBB" "D4D3DD"


kyoto : AngleOrDirection c -> Style
kyoto =
    gradient2 "c21500" "ffc500"


mistyMeadow : AngleOrDirection c -> Style
mistyMeadow =
    gradient2 "215f00" "e4e4d9"


aqualicious : AngleOrDirection c -> Style
aqualicious =
    gradient2 "50C9C3" "96DEDA"


moor : AngleOrDirection c -> Style
moor =
    gradient2 "616161" "9bc5c3"


almost : AngleOrDirection c -> Style
almost =
    gradient2 "ddd6f3" "faaca8"


foreverLost : AngleOrDirection c -> Style
foreverLost =
    gradient2 "5D4157" "A8CABA"


winter : AngleOrDirection c -> Style
winter =
    gradient2 "E6DADA" "274046"


autumn : AngleOrDirection c -> Style
autumn =
    gradient2 "DAD299" "B0DAB9"


candy : AngleOrDirection c -> Style
candy =
    gradient2 "D3959B" "BFE6BA"


reef : AngleOrDirection c -> Style
reef =
    gradient2 "00d2ff" "3a7bd5"


theStrain : AngleOrDirection c -> Style
theStrain =
    gradient2 "870000" "190A05"


dirtyFog : AngleOrDirection c -> Style
dirtyFog =
    gradient2 "B993D6" "8CA6DB"


earthly : AngleOrDirection c -> Style
earthly =
    gradient2 "649173" "DBD5A4"


virgin : AngleOrDirection c -> Style
virgin =
    gradient2 "C9FFBF" "FFAFBD"


ash : AngleOrDirection c -> Style
ash =
    gradient2 "606c88" "3f4c6b"


shadowNight : AngleOrDirection c -> Style
shadowNight =
    gradient2 "000000" "53346D"


cherryblossoms : AngleOrDirection c -> Style
cherryblossoms =
    gradient2 "FBD3E9" "BB377D"


parklife : AngleOrDirection c -> Style
parklife =
    gradient2 "ADD100" "7B920A"


danceToForget : AngleOrDirection c -> Style
danceToForget =
    gradient2 "FF4E50" "F9D423"


starfall : AngleOrDirection c -> Style
starfall =
    gradient2 "F0C27B" "4B1248"


redMist : AngleOrDirection c -> Style
redMist =
    gradient2 "000000" "e74c3c"


tealLove : AngleOrDirection c -> Style
tealLove =
    gradient2 "AAFFA9" "11FFBD"


neonLife : AngleOrDirection c -> Style
neonLife =
    gradient2 "B3FFAB" "12FFF7"


manOfSteel : AngleOrDirection c -> Style
manOfSteel =
    gradient2 "780206" "061161"


amethyst : AngleOrDirection c -> Style
amethyst =
    gradient2 "9D50BB" "6E48AA"


cheerUpEmoKid : AngleOrDirection c -> Style
cheerUpEmoKid =
    gradient2 "556270" "FF6B6B"


shore : AngleOrDirection c -> Style
shore =
    gradient2 "70e1f5" "ffd194"


facebookMessenger : AngleOrDirection c -> Style
facebookMessenger =
    gradient2 "00c6ff" "0072ff"


soundcloud : AngleOrDirection c -> Style
soundcloud =
    gradient2 "fe8c00" "f83600"


behongo : AngleOrDirection c -> Style
behongo =
    gradient2 "52c234" "061700"


servquick : AngleOrDirection c -> Style
servquick =
    gradient2 "485563" "29323c"


friday : AngleOrDirection c -> Style
friday =
    gradient2 "83a4d4" "b6fbff"


martini : AngleOrDirection c -> Style
martini =
    gradient2 "FDFC47" "24FE41"


metallicToad : AngleOrDirection c -> Style
metallicToad =
    gradient2 "abbaab" "ffffff"


betweenTheClouds : AngleOrDirection c -> Style
betweenTheClouds =
    gradient2 "73C8A9" "373B44"


crazyOrangeI : AngleOrDirection c -> Style
crazyOrangeI =
    gradient2 "D38312" "A83279"


hersheys : AngleOrDirection c -> Style
hersheys =
    gradient2 "1e130c" "9a8478"


talkingToMiceElf : AngleOrDirection c -> Style
talkingToMiceElf =
    gradient2 "948E99" "2E1437"


purpleBliss : AngleOrDirection c -> Style
purpleBliss =
    gradient2 "360033" "0b8793"


predawn : AngleOrDirection c -> Style
predawn =
    gradient2 "FFA17F" "00223E"


endlessRiver : AngleOrDirection c -> Style
endlessRiver =
    gradient2 "43cea2" "185a9d"


pastelOrangeAtTheSun : AngleOrDirection c -> Style
pastelOrangeAtTheSun =
    gradient2 "ffb347" "ffcc33"


twitch : AngleOrDirection c -> Style
twitch =
    gradient2 "6441A5" "2a0845"


atlas : AngleOrDirection c -> Style
atlas =
    gradient3 "FEAC5E" "C779D0" "4BC0C8"


instagram : AngleOrDirection c -> Style
instagram =
    gradient3 "833ab4" "fd1d1d" "fcb045"


flickr : AngleOrDirection c -> Style
flickr =
    gradient2 "ff0084" "33001b"


vine : AngleOrDirection c -> Style
vine =
    gradient2 "00bf8f" "001510"


turquoiseFlow : AngleOrDirection c -> Style
turquoiseFlow =
    gradient2 "136a8a" "267871"


portrait : AngleOrDirection c -> Style
portrait =
    gradient2 "8e9eab" "eef2f3"


virginAmerica : AngleOrDirection c -> Style
virginAmerica =
    gradient2 "7b4397" "dc2430"


kokoCaramel : AngleOrDirection c -> Style
kokoCaramel =
    gradient2 "D1913C" "FFD194"


freshTurboscent : AngleOrDirection c -> Style
freshTurboscent =
    gradient2 "F1F2B5" "135058"


greenToDark : AngleOrDirection c -> Style
greenToDark =
    gradient2 "6A9113" "141517"


ukraine : AngleOrDirection c -> Style
ukraine =
    gradient2 "004FF9" "FFF94C"


curiosityBlue : AngleOrDirection c -> Style
curiosityBlue =
    gradient2 "525252" "3d72b4"


darkKnight : AngleOrDirection c -> Style
darkKnight =
    gradient2 "BA8B02" "181818"


piglet : AngleOrDirection c -> Style
piglet =
    gradient2 "ee9ca7" "ffdde1"


lizard : AngleOrDirection c -> Style
lizard =
    gradient2 "304352" "d7d2cc"


sagePersuasion : AngleOrDirection c -> Style
sagePersuasion =
    gradient2 "CCCCB2" "757519"


betweenNightAndDay : AngleOrDirection c -> Style
betweenNightAndDay =
    gradient2 "2c3e50" "3498db"


timber : AngleOrDirection c -> Style
timber =
    gradient2 "fc00ff" "00dbde"


passion : AngleOrDirection c -> Style
passion =
    gradient2 "e53935" "e35d5b"


clearSky : AngleOrDirection c -> Style
clearSky =
    gradient2 "005C97" "363795"


masterCard : AngleOrDirection c -> Style
masterCard =
    gradient2 "f46b45" "eea849"


backToEarth : AngleOrDirection c -> Style
backToEarth =
    gradient2 "00C9FF" "92FE9D"


deepPurple : AngleOrDirection c -> Style
deepPurple =
    gradient2 "673AB7" "512DA8"


littleLeaf : AngleOrDirection c -> Style
littleLeaf =
    gradient2 "76b852" "8DC26F"


netflix : AngleOrDirection c -> Style
netflix =
    gradient2 "8E0E00" "1F1C18"


lightOrange : AngleOrDirection c -> Style
lightOrange =
    gradient2 "FFB75E" "ED8F03"


greenAndBlue : AngleOrDirection c -> Style
greenAndBlue =
    gradient2 "c2e59c" "64b3f4"


poncho : AngleOrDirection c -> Style
poncho =
    gradient2 "403A3E" "BE5869"


backToTheFuture : AngleOrDirection c -> Style
backToTheFuture =
    gradient2 "C02425" "F0CB35"


blush : AngleOrDirection c -> Style
blush =
    gradient2 "B24592" "F15F79"


inbox : AngleOrDirection c -> Style
inbox =
    gradient2 "457fca" "5691c8"


purplin : AngleOrDirection c -> Style
purplin =
    gradient2 "6a3093" "a044ff"


paleWood : AngleOrDirection c -> Style
paleWood =
    gradient2 "eacda3" "d6ae7b"


haikus : AngleOrDirection c -> Style
haikus =
    gradient2 "fd746c" "ff9068"


pizelex : AngleOrDirection c -> Style
pizelex =
    gradient2 "114357" "F29492"


joomla : AngleOrDirection c -> Style
joomla =
    gradient2 "1e3c72" "2a5298"


christmas : AngleOrDirection c -> Style
christmas =
    gradient2 "2F7336" "AA3A38"


minnesotaVikings : AngleOrDirection c -> Style
minnesotaVikings =
    gradient2 "5614B0" "DBD65C"


miamiDolphins : AngleOrDirection c -> Style
miamiDolphins =
    gradient2 "4DA0B0" "D39D38"


forest : AngleOrDirection c -> Style
forest =
    gradient2 "5A3F37" "2C7744"


nighthawk : AngleOrDirection c -> Style
nighthawk =
    gradient2 "2980b9" "2c3e50"


superman : AngleOrDirection c -> Style
superman =
    gradient2 "0099F7" "F11712"


suzy : AngleOrDirection c -> Style
suzy =
    gradient2 "834d9b" "d04ed6"


darkSkies : AngleOrDirection c -> Style
darkSkies =
    gradient2 "4B79A1" "283E51"


deepSpace : AngleOrDirection c -> Style
deepSpace =
    gradient2 "000000" "434343"


decent : AngleOrDirection c -> Style
decent =
    gradient2 "4CA1AF" "C4E0E5"


colorsOfSky : AngleOrDirection c -> Style
colorsOfSky =
    gradient2 "E0EAFC" "CFDEF3"


purpleWhite : AngleOrDirection c -> Style
purpleWhite =
    gradient2 "BA5370" "F4E2D8"


ali : AngleOrDirection c -> Style
ali =
    gradient2 "ff4b1f" "1fddff"


alihossein : AngleOrDirection c -> Style
alihossein =
    gradient2 "f7ff00" "db36a4"


shahabi : AngleOrDirection c -> Style
shahabi =
    gradient2 "a80077" "66ff00"


redOcean : AngleOrDirection c -> Style
redOcean =
    gradient2 "1D4350" "A43931"


tranquil : AngleOrDirection c -> Style
tranquil =
    gradient2 "EECDA3" "EF629F"


transfile : AngleOrDirection c -> Style
transfile =
    gradient2 "16BFFD" "CB3066"


sylvia : AngleOrDirection c -> Style
sylvia =
    gradient2 "ff4b1f" "ff9068"


sweetMorning : AngleOrDirection c -> Style
sweetMorning =
    gradient2 "FF5F6D" "FFC371"


politics : AngleOrDirection c -> Style
politics =
    gradient2 "2196f3" "f44336"


brightVault : AngleOrDirection c -> Style
brightVault =
    gradient2 "00d2ff" "928DAB"


solidVault : AngleOrDirection c -> Style
solidVault =
    gradient2 "3a7bd5" "3a6073"


sunset : AngleOrDirection c -> Style
sunset =
    gradient2 "0B486B" "F56217"


grapefruitSunset : AngleOrDirection c -> Style
grapefruitSunset =
    gradient2 "e96443" "904e95"


deepSeaSpace : AngleOrDirection c -> Style
deepSeaSpace =
    gradient2 "2C3E50" "4CA1AF"


dusk : AngleOrDirection c -> Style
dusk =
    gradient2 "2C3E50" "FD746C"


minimalRed : AngleOrDirection c -> Style
minimalRed =
    gradient2 "F00000" "DC281E"


royal : AngleOrDirection c -> Style
royal =
    gradient2 "141E30" "243B55"


mauve : AngleOrDirection c -> Style
mauve =
    gradient2 "42275a" "734b6d"


frost : AngleOrDirection c -> Style
frost =
    gradient2 "000428" "004e92"


lush : AngleOrDirection c -> Style
lush =
    gradient2 "56ab2f" "a8e063"


firewatch : AngleOrDirection c -> Style
firewatch =
    gradient2 "cb2d3e" "ef473a"


sherbert : AngleOrDirection c -> Style
sherbert =
    gradient2 "f79d00" "64f38c"


bloodRed : AngleOrDirection c -> Style
bloodRed =
    gradient2 "f85032" "e73827"


sunOnTheHorizon : AngleOrDirection c -> Style
sunOnTheHorizon =
    gradient2 "fceabb" "f8b500"


iiitDelhi : AngleOrDirection c -> Style
iiitDelhi =
    gradient2 "808080" "3fada8"


dusk2 : AngleOrDirection c -> Style
dusk2 =
    gradient2 "ffd89b" "19547b"


fiftyShadesOfGrey : AngleOrDirection c -> Style
fiftyShadesOfGrey =
    gradient2 "bdc3c7" "2c3e50"


dania : AngleOrDirection c -> Style
dania =
    gradient2 "BE93C5" "7BC6CC"


limeade : AngleOrDirection c -> Style
limeade =
    gradient2 "A1FFCE" "FAFFD1"


disco : AngleOrDirection c -> Style
disco =
    gradient2 "4ECDC4" "556270"


loveCouple : AngleOrDirection c -> Style
loveCouple =
    gradient2 "3a6186" "89253e"


azurePop : AngleOrDirection c -> Style
azurePop =
    gradient2 "ef32d9" "89fffd"


nepal : AngleOrDirection c -> Style
nepal =
    gradient2 "de6161" "2657eb"


cosmicFusion : AngleOrDirection c -> Style
cosmicFusion =
    gradient2 "ff00cc" "333399"


snapchat : AngleOrDirection c -> Style
snapchat =
    gradient2 "fffc00" "ffffff"


edsSunsetGradient : AngleOrDirection c -> Style
edsSunsetGradient =
    gradient2 "ff7e5f" "feb47b"


bradyBradyFunFun : AngleOrDirection c -> Style
bradyBradyFunFun =
    gradient2 "00c3ff" "ffff1c"


blackRose : AngleOrDirection c -> Style
blackRose =
    gradient2 "f4c4f3" "fc67fa"


eightysPurple : AngleOrDirection c -> Style
eightysPurple =
    gradient2 "41295a" "2F0743"


radar : AngleOrDirection c -> Style
radar =
    gradient3 "A770EF" "CF8BF3" "FDB99B"


ibizaSunset : AngleOrDirection c -> Style
ibizaSunset =
    gradient2 "ee0979" "ff6a00"


dawn : AngleOrDirection c -> Style
dawn =
    gradient2 "F3904F" "3B4371"


mild : AngleOrDirection c -> Style
mild =
    gradient2 "67B26F" "4ca2cd"


viceCity : AngleOrDirection c -> Style
viceCity =
    gradient2 "3494E6" "EC6EAD"


jaipur : AngleOrDirection c -> Style
jaipur =
    gradient2 "DBE6F6" "C5796D"


cocoaaIce : AngleOrDirection c -> Style
cocoaaIce =
    gradient2 "c0c0aa" "1cefff"


easymed : AngleOrDirection c -> Style
easymed =
    gradient2 "DCE35B" "45B649"


roseColoredLenses : AngleOrDirection c -> Style
roseColoredLenses =
    gradient2 "E8CBC0" "636FA4"


whatLiesBeyond : AngleOrDirection c -> Style
whatLiesBeyond =
    gradient2 "F0F2F0" "000C40"


roseanna : AngleOrDirection c -> Style
roseanna =
    gradient2 "FFAFBD" "ffc3a0"


honeyDew : AngleOrDirection c -> Style
honeyDew =
    gradient2 "43C6AC" "F8FFAE"


underTheLake : AngleOrDirection c -> Style
underTheLake =
    gradient2 "093028" "237A57"


theBlueLagoon : AngleOrDirection c -> Style
theBlueLagoon =
    gradient2 "43C6AC" "191654"


canYouFeelTheLoveTonight : AngleOrDirection c -> Style
canYouFeelTheLoveTonight =
    gradient2 "4568DC" "B06AB3"


veryBlue : AngleOrDirection c -> Style
veryBlue =
    gradient2 "0575E6" "021B79"


loveAndLiberty : AngleOrDirection c -> Style
loveAndLiberty =
    gradient2 "200122" "6f0000"


orca : AngleOrDirection c -> Style
orca =
    gradient2 "44A08D" "093637"


venice : AngleOrDirection c -> Style
venice =
    gradient2 "6190E8" "A7BFE8"


pacificDream : AngleOrDirection c -> Style
pacificDream =
    gradient2 "34e89e" "0f3443"


learningAndLeading : AngleOrDirection c -> Style
learningAndLeading =
    gradient2 "F7971E" "FFD200"


celestial : AngleOrDirection c -> Style
celestial =
    gradient2 "C33764" "1D2671"


purplepine : AngleOrDirection c -> Style
purplepine =
    gradient2 "20002c" "cbb4d4"


shaLaLa : AngleOrDirection c -> Style
shaLaLa =
    gradient2 "D66D75" "E29587"


mini : AngleOrDirection c -> Style
mini =
    gradient2 "30E8BF" "FF8235"


maldives : AngleOrDirection c -> Style
maldives =
    gradient2 "B2FEFA" "0ED2F7"


cinnamint : AngleOrDirection c -> Style
cinnamint =
    gradient2 "4AC29A" "BDFFF3"


html : AngleOrDirection c -> Style
html =
    gradient2 "E44D26" "F16529"


coal : AngleOrDirection c -> Style
coal =
    gradient2 "EB5757" "000000"


sunkist : AngleOrDirection c -> Style
sunkist =
    gradient2 "F2994A" "F2C94C"


blueSkies : AngleOrDirection c -> Style
blueSkies =
    gradient2 "56CCF2" "2F80ED"


chittyChittyBangBang : AngleOrDirection c -> Style
chittyChittyBangBang =
    gradient2 "007991" "78ffd6"


visionsOfGrandeur : AngleOrDirection c -> Style
visionsOfGrandeur =
    gradient2 "000046" "1CB5E0"


crystalClear : AngleOrDirection c -> Style
crystalClear =
    gradient2 "159957" "155799"


mello : AngleOrDirection c -> Style
mello =
    gradient2 "c0392b" "8e44ad"


compareNow : AngleOrDirection c -> Style
compareNow =
    gradient2 "EF3B36" "FFFFFF"


meridian : AngleOrDirection c -> Style
meridian =
    gradient2 "283c86" "45a247"


relay : AngleOrDirection c -> Style
relay =
    gradient3 "3A1C71" "D76D77" "FFAF7B"


alive : AngleOrDirection c -> Style
alive =
    gradient2 "CB356B" "BD3F32"


scooter : AngleOrDirection c -> Style
scooter =
    gradient2 "36D1DC" "5B86E5"


terminal : AngleOrDirection c -> Style
terminal =
    gradient2 "000000" "0f9b0f"


telegram : AngleOrDirection c -> Style
telegram =
    gradient2 "1c92d2" "f2fcfe"


crimsonTide : AngleOrDirection c -> Style
crimsonTide =
    gradient2 "642B73" "C6426E"


socialive : AngleOrDirection c -> Style
socialive =
    gradient2 "06beb6" "48b1bf"


subu : AngleOrDirection c -> Style
subu =
    gradient3 "0cebeb" "20e3b2" "29ffc6"


shift : AngleOrDirection c -> Style
shift =
    gradient3 "000000" "E5008D" "FF070B"


clot : AngleOrDirection c -> Style
clot =
    gradient3 "070000" "4C0001" "070000"


brokenHearts : AngleOrDirection c -> Style
brokenHearts =
    gradient2 "d9a7c7" "fffcdc"


kimobyIsTheNewBlue : AngleOrDirection c -> Style
kimobyIsTheNewBlue =
    gradient2 "396afc" "2948ff"


dull : AngleOrDirection c -> Style
dull =
    gradient2 "C9D6FF" "E2E2E2"


purpink : AngleOrDirection c -> Style
purpink =
    gradient2 "7F00FF" "E100FF"


orangeCoral : AngleOrDirection c -> Style
orangeCoral =
    gradient2 "ff9966" "ff5e62"


summer : AngleOrDirection c -> Style
summer =
    gradient2 "22c1c3" "fdbb2d"


kingYna : AngleOrDirection c -> Style
kingYna =
    gradient3 "1a2a6c" "b21f1f" "fdbb2d"


velvetSun : AngleOrDirection c -> Style
velvetSun =
    gradient2 "e1eec3" "f05053"
