package libdnd
import "characters"
import "cities"
import "core:fmt"
import "core:mem"
import "utils"

main :: proc() {
	alloc, _h := utils.create_arena()
	defer utils.destroy_arena(_h)
	town := cities.create_town(cities.random_water(), 2000, 0., alloc)
	cities.town_render2d(town, "test.png")
}
