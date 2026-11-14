package libdnd
import "characters"
import "cities"
import "core:fmt"
import "core:mem"
import "utils"

main :: proc() {
	alloc, _h := utils.create_arena()
	defer utils.destroy_arena(_h)
	town := cities.create_town(.CoastWest, 2000, 1., alloc)
	cities.town_render2d(town, "test.png")
}
