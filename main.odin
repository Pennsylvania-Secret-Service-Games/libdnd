package libdnd
import "core:fmt"
import "core:mem"
main :: proc() {
	arena: mem.Dynamic_Arena
	mem.dynamic_arena_init(&arena)
	defer mem.dynamic_arena_destroy(&arena)
	alloc := mem.dynamic_arena_allocator(&arena)
	char := generate_character(10, .Oeridian, .Human, .MagicUser, alloc)
	fmt.printf("%#v\n", char)
}
