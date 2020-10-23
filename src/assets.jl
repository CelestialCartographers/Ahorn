module Assets

using ..Ahorn
using Cairo

const crowIdle = open(Cairo.read_from_png, Ahorn.abs"../assets/crow18.png")
const crowPeck1 = open(Cairo.read_from_png, Ahorn.abs"../assets/crow20.png")
const crowPeck2 = open(Cairo.read_from_png, Ahorn.abs"../assets/crow21.png")

const risingLava = open(Cairo.read_from_png, Ahorn.abs"../assets/rising_lava.png")
const lavaSandwich = open(Cairo.read_from_png, Ahorn.abs"../assets/lava_sandwich.png")
const speechBubble = open(Cairo.read_from_png, Ahorn.abs"../assets/core_message.png")
const speaker = open(Cairo.read_from_png, Ahorn.abs"../assets/sound_source.png")
const tentacle = open(Cairo.read_from_png, Ahorn.abs"../assets/tentacles.png")
const northernLights = open(Cairo.read_from_png, Ahorn.abs"../assets/northern_lights.png")
const summitBackgroundManager = open(Cairo.read_from_png, Ahorn.abs"../assets/summit_background_manager.png")
const cutsceneNode = open(Cairo.read_from_png, Ahorn.abs"../assets/cutscene_node.png")

const missingImage = open(Cairo.read_from_png, Ahorn.abs"../assets/missing_image.png")

# For backwards compability... Spelling words is sometimes too hard...
const lavaSanwitch = lavaSandwich

end