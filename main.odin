package libdnd
import "core:fmt"
import "core:mem"
main :: proc() {
	arena: mem.Dynamic_Arena
	mem.dynamic_arena_init(&arena)
	defer mem.dynamic_arena_destroy(&arena)
	alloc := mem.dynamic_arena_allocator(&arena)
	char := generate_character(2, .Oeridian, .Human, .Thief, alloc)
	fmt.printf("%#v\n", format_character(char, alloc))
}
