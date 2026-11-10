package libdnd
import "core:math/rand"
choise :: proc(list: []$T) -> T {
	return rand.choice(list)
}

choose_set :: proc(list: []$T, count: int, allocator := context.allocator) -> []T {
	out := make([dynamic]T, allocator)
	base := make([dynamic]T)
	defer delete(base)
	reserve(&base, len(list))
	for i in list {
		append(&base, i)
	}
	for i in 0 ..< count {
		idx := rand.int_range(0, len(base))
		tmp := base[idx]
		unordered_remove(&base, idx)
		append(&out, tmp)
	}
	return out[:]
}
