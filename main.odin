package libdnd
import "characters"
import "cities"
import "core:fmt"
import "core:mem"
import "utils"

main :: proc() {
	arena: mem.Dynamic_Arena
	mem.dynamic_arena_init(&arena)
	defer mem.dynamic_arena_destroy(&arena)
	alloc := mem.dynamic_arena_allocator(&arena)
	//	char := characters.generate_character(5, .Baklunish, .Human, .Cleric, alloc)
	//fmt.printf("%#v\n", characters.format_character(char, alloc))
	cities.create_town(alloc, 100)
}
