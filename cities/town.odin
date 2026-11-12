package cities
import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:mem"
import "core:slice"
import "core:sort"
import "vendor:raylib"
import "vendor:raylib/rlgl"
Vec2 :: raylib.Vector2
WIDTH :: 1000
HEIGHT :: 1000

Point :: struct {
	x: i32,
	y: i32,
}

Edge :: struct {
	start:   ^Point,
	end:     ^Point,
	touched: bool,
}

OwnedEdge :: struct {
	start: Point,
	end:   Point,
}

Building :: struct {
	center:   Point,
	width:    i32,
	height:   i32,
	rotation: f32,
}

Town :: struct {
	points:    [dynamic]^Point,
	edges:     [dynamic]^Edge,
	buildings: [dynamic]^Building,
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
point_to_vec2 :: proc(p: Point) -> Vec2 {
	return Vec2{cast(f32)p.x, cast(f32)p.y}
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
vec2_to_point :: proc(v: Vec2) -> Point {return Point{cast(i32)v.x, cast(i32)v.y}}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
point_distance_to_point :: proc(p1: Point, p2: Point) -> f32 {
	dx := cast(f32)(p1.x - p2.x)
	dy := cast(f32)(p1.y - p2.y)
	return math.sqrt(dx * dx + dy * dy)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
distance_to_edge :: proc(p: Point, e: OwnedEdge) -> f32 {
	p0 := point_to_vec2(p)
	s := point_to_vec2(e.start)
	e := point_to_vec2(e.end)
	l := raylib.Vector2Distance(s, e)
	min_dist := raylib.Vector2DistanceSqr(p0, s)
	if l == 0 {
		return min_dist
	}
	iter_count := cast(i32)math.ceil(l)
	for i in 0 ..= iter_count {
		t := cast(f32)i / cast(f32)iter_count
		p_prime := s * (1 - t) + e * t
		dist := raylib.Vector2DistanceSqr(p0, p_prime)
		if dist < min_dist {
			min_dist = dist
		}
	}
	return min_dist
}


@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
distance_between_edges :: proc(e1: OwnedEdge, e2: OwnedEdge) -> f32 {
	s := point_to_vec2(e1.start)
	e := point_to_vec2(e1.end)
	l := raylib.Vector2Distance(s, e)
	min_dist := distance_to_edge(e1.start, e2)
	iter_count := cast(i32)math.ceil(l)
	for i in 0 ..= iter_count {
		t := cast(f32)i / cast(f32)iter_count
		p_prime := vec2_to_point(s * (1 - t) + e * t)
		d := distance_to_edge(p_prime, e2)
		if d < min_dist {
			min_dist = d
		}
	}
	return min_dist
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_rotation :: proc(e: Edge) -> f32 {
	delta := point_to_vec2(e.end^) - point_to_vec2(e.start^)
	return math.atan2(delta.y, delta.x)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_forward_vector :: proc(e: Edge) -> raylib.Vector2 {
	ang := edge_rotation(e)
	return raylib.Vector2Normalize(edge_end_vector(e) - edge_start_vector(e))
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_right_vector :: proc(e: Edge) -> raylib.Vector2 {
	return raylib.Vector2Rotate(
		raylib.Vector2Normalize(edge_end_vector(e) - edge_start_vector(e)),
		math.PI / 2,
	)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_start_vector :: proc(e: Edge) -> raylib.Vector2 {
	return point_to_vec2(e.start^)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_end_vector :: proc(e: Edge) -> raylib.Vector2 {
	return point_to_vec2(e.end^)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_length :: proc(e: ^Edge) -> f32 {
	return point_distance_to_point(e.start^, e.end^)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
building_to_vertices :: proc(b: Building) -> [4]Vec2 {
	w := cast(f32)b.width / 2
	h := cast(f32)b.height / 2
	pos := point_to_vec2(b.center)
	p0: raylib.Vector2 = {w, h}
	p1: raylib.Vector2 = {-w, h}
	p2: raylib.Vector2 = {-w, -h}
	p3: raylib.Vector2 = {w, -h}
	p0 = raylib.Vector2Rotate(p0, b.rotation)
	p1 = raylib.Vector2Rotate(p1, b.rotation)
	p2 = raylib.Vector2Rotate(p2, b.rotation)
	p3 = raylib.Vector2Rotate(p3, b.rotation)
	p0 += pos
	p1 += pos
	p2 += pos
	p3 += pos
	return {p0, p1, p2, p3}
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
building_to_triangles :: proc(b: Building) -> [2][3]Vec2 {
	w := cast(f32)b.width / 2
	h := cast(f32)b.height / 2
	pos := point_to_vec2(b.center)
	p0: raylib.Vector2 = {w, h}
	p1: raylib.Vector2 = {-w, h}
	p2: raylib.Vector2 = {-w, -h}
	p3: raylib.Vector2 = {w, -h}
	p0 = raylib.Vector2Rotate(p0, b.rotation)
	p1 = raylib.Vector2Rotate(p1, b.rotation)
	p2 = raylib.Vector2Rotate(p2, b.rotation)
	p3 = raylib.Vector2Rotate(p3, b.rotation)
	p0 += pos
	p1 += pos
	p2 += pos
	p3 += pos
	t1: [3]Vec2 = {p0, p1, p2}
	t2: [3]Vec2 = {p2, p3, p0}
	return {t1, t2}
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
building_check_collision :: proc(b1: Building, b2: Building) -> bool {
	trs1 := building_to_triangles(b1)
	trs2 := building_to_triangles(b2)
	for i in trs1 {
		for j in trs2 {
			for di in 0 ..= 2 {
				for dj in 0 ..= 2 {
					if raylib.CheckCollisionLines(
						i[di],
						i[(di + 1) % 3],
						j[dj],
						j[(dj + 1) % 3],
						nil,
					) {
						return true
					}
				}
			}
			for dj in j {
				if raylib.CheckCollisionPointTriangle(dj, i[0], i[1], i[2]) {
					return true
				}
			}
			for di in i {
				if raylib.CheckCollisionPointTriangle(di, j[0], j[1], j[2]) {
					return true
				}
			}
		}
	}
	return false
}

building_render_to_image :: proc(img: ^raylib.Image, b: Building, color: raylib.Color) {
	tris := building_to_vertices(b)
	for i in 0 ..< 4 {
		raylib.ImageDrawLineV(img, tris[i], tris[(i + 1) % 4], color)
	}
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
town_has_edge :: proc(this: ^Town, e: Edge) -> bool {
	for i in this.edges {
		if (i.end == e.end && i.start == e.start) || (i.start == e.end && i.end == e.start) {
			return true
		}
		{
			THRESH :: (math.PI / 2) * 0.4
			if (i.start == e.start) {
				d0 := point_to_vec2(e.end^) - point_to_vec2(i.start^)
				d1 := point_to_vec2(i.end^) - point_to_vec2(i.start^)
				if raylib.Vector2Angle(d0, d1) < THRESH {
					return true
				}
			} else if (i.start == e.end) {
				d0 := point_to_vec2(e.start^) - point_to_vec2(i.start^)
				d1 := point_to_vec2(i.end^) - point_to_vec2(i.start^)
				if raylib.Vector2Angle(d0, d1) < THRESH {
					return true
				}
			} else if (i.end == e.start) {
				d0 := point_to_vec2(e.end^) - point_to_vec2(i.end^)
				d1 := point_to_vec2(i.start^) - point_to_vec2(i.end^)
				if raylib.Vector2Angle(d0, d1) < THRESH {
					return true
				}
			} else if (i.end == e.end) {
				d0 := point_to_vec2(e.start^) - point_to_vec2(i.end^)
				d1 := point_to_vec2(i.start^) - point_to_vec2(i.end^)
				if raylib.Vector2Angle(d0, d1) < THRESH {
					return true
				}
			}
		}
	}
	return false
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_intersects :: proc(this: ^Town, e: Edge) -> bool {
	start := point_to_vec2(e.start^)
	end := point_to_vec2(e.end^)
	for i in this.edges {
		if (i.start == e.end || i.end == e.end) || (i.start == e.start || i.end == e.end) {
			continue
		}
		start0 := point_to_vec2(i.start^)
		end0 := point_to_vec2(i.end^)
		if raylib.CheckCollisionLines(start, end, start0, end0, nil) {
			return true
		}
	}
	return false
}

rand_point :: proc() -> Point {
	return {rand.int32_range(0, WIDTH), rand.int32_range(0, HEIGHT)}
}

generate_points :: proc(this: ^Town, point_count: int) {
	TILE_SIZE :: 40
	reserve(&this.points, WIDTH * HEIGHT / (TILE_SIZE * TILE_SIZE))
	for x in 0 ..< cast(i32)(WIDTH / TILE_SIZE) {
		for y in 0 ..< cast(i32)(HEIGHT / TILE_SIZE) {
			pos := Point{x * TILE_SIZE, y * TILE_SIZE}
			pos.x += rand.int32_range(0, TILE_SIZE / 2) + TILE_SIZE / 4
			pos.y += rand.int32_range(0, TILE_SIZE / 2) + TILE_SIZE / 4
			append(&this.points, new_clone(pos))
		}
	}
}


generate_edges :: proc(this: ^Town) {
	points2 := slice.clone(this.points[:])
	for &i, idx in this.points {
		hit_count := 0
		rand.shuffle(points2)
		candidate_count := rand.int_range(2, 10)
		for &j, idx2 in this.points {
			if hit_count >= candidate_count {
				break
			}
			if idx == idx2 {
				continue
			}
			ed := Edge{i, j, false}
			d := point_distance_to_point(i^, j^)
			if d < 200 {
				if !town_has_edge(this, ed) {
					if !edge_intersects(this, ed) {
						append(&this.edges, new_clone(ed))
						hit_count += 1
					}
				}
			}
		}
	}
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
town_can_place_building :: proc(this: ^Town, b: Building) -> bool {
	tris := building_to_triangles(b)
	for i in this.buildings {
		if building_check_collision(i^, b) {
			return false
		}
	}
	for i in this.edges {
		es := edge_start_vector(i^)
		ee := edge_end_vector(i^)
		for j in tris {
			for dj in 0 ..< 3 {
				js := j[dj]
				je := j[(dj + 1) % 3]
				if raylib.CheckCollisionLines(es, ee, js, je, nil) {
					return false
				}
			}
		}
	}
	return true
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
generate_buildings :: proc(this: ^Town, building_count: int) {
	edge_list := slice.clone(this.edges[:])
	defer delete(edge_list)
	sort.quick_sort_proc(edge_list, proc(x: ^Edge, y: ^Edge) -> int {
		pos := Point{WIDTH / 2, HEIGHT / 2}
		dx := distance_to_edge(pos, {x.start^, x.end^})
		dy := distance_to_edge(pos, {y.start^, y.end^})
		return sort.compare_f32s(dx, dy)
	})
	for i in edge_list {
		b_list := make([dynamic]^Building)
		start := edge_start_vector(i^)
		dist := edge_length(i)
		frw := edge_forward_vector(i^)
		rgt := edge_right_vector(i^)
		rot := edge_rotation(i^)
		sign: f32 = 1
		for _i in 0 ..= 1 {
			dy: f32 = 0
			for dy < dist {
				width: i32 = rand.int32_range(6, 11)
				height: i32 = 0
				SHIFT :: 2
				ROT_SHIFT :: 0.
				base_h := rand.int_range(10, 15)
				for dh in 0 ..= 8 {
					if base_h - dh < 5 {
						break
					}
					th := cast(i32)(base_h - dh)
					b: Building
					b.rotation = rot + ROT_SHIFT
					b.center = vec2_to_point(
						frw * (dy + (cast(f32)width / 2)) +
						(cast(f32)th / 2 + SHIFT) * sign * rgt +
						start,
					)
					b.height = th
					b.width = width
					if town_can_place_building(this, b) {
						height = th
						break
					}
				}
				if height == 0 {
					dy += cast(f32)width / 2
					continue
				}
				b: Building
				b.rotation = rot + ROT_SHIFT
				b.center = vec2_to_point(
					frw * (dy + (cast(f32)width / 2)) +
					(cast(f32)height / 2 + SHIFT) * sign * rgt +
					start,
				)
				b.height = height
				b.width = width
				b2 := new_clone(b)
				i.touched = true
				append(&this.buildings, b2)
				dy += cast(f32)width + 1
			}
			sign = -1
		}
		fmt.printf("building count:%d\n", len(this.buildings))
		if len(this.buildings) >= building_count {
			break
		}
	}
}

create_town :: proc(alloc: mem.Allocator, building_count: int) -> ^Town {
	context.allocator = alloc
	this := new(Town)
	this.edges = make([dynamic]^Edge)
	this.points = make([dynamic]^Point)
	this.buildings = make([dynamic]^Building)
	generate_points(this, WIDTH * HEIGHT / 100)
	generate_edges(this)
	generate_buildings(this, building_count)
	dbg := raylib.GenImageColor(WIDTH, HEIGHT, raylib.WHITE)
	defer raylib.UnloadImage(dbg)
	for i in this.edges {
		raylib.ImageDrawLine(&dbg, i.start.x, i.start.y, i.end.x, i.end.y, raylib.LIGHTGRAY)

	}
	for i in this.buildings {
		building_render_to_image(&dbg, i^, raylib.BLACK)
	}
	raylib.ExportImage(dbg, "test.png")
	return this
}
