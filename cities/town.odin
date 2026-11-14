package cities
import "core:container/intrusive/list"
import "core:encoding/ini"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/noise"
import "core:math/rand"
import "core:mem"
import "core:slice"
import "core:sort"
import "core:strings"
import "vendor:ENet"
import "vendor:directx/d3d12"
import "vendor:raylib"
import "vendor:raylib/rlgl"
Vec2 :: raylib.Vector2
/*
start with a body of water
around the body of water
@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
*/
TILE_SIZE :: 50
ROAD_WIDTH :: 5
LARGE_ROAD_WIDTH :: 10
WaterPoint :: struct {
	pos:    Vec2,
	radius: f32,
}

Edge :: struct {
	start:    ^Vec2,
	end:      ^Vec2,
	width:    f32,
	is_ghost: bool,
}

Wall :: struct {
	start:    ^Vec2,
	end:      ^Vec2,
	is_ghost: bool,
}
Point :: struct {
	x: i32,
	y: i32,
}

Building :: struct {
	center:   Vec2,
	width:    f32,
	height:   f32,
	rotation: f32,
}

Town :: struct {
	grid:      map[Point]^Vec2,
	petals:    [dynamic]Vec2,
	water:     [dynamic]^WaterPoint,
	points:    [dynamic]^Vec2,
	edges:     [dynamic]^Edge,
	buildings: [dynamic]^Building,
	walls:     [dynamic]Wall,
	width:     f32,
	height:    f32,
	center:    Vec2,
	allowed:   raylib.Rectangle,
}


WaterShape :: enum {
	RiverNorthSouth,
	RiverEastWest,
	CoastNorth,
	CoastSouth,
	CoastEast,
	CoastWest,
	LakeCenter,
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
building_to_rectangle :: proc(b: Building) -> raylib.Rectangle {
	verts := building_to_vertices(b)
	min_x := verts[0].x
	min_y := verts[0].y
	max_x := min_x
	max_y := min_y
	for i in verts {
		if i.x < min_x {
			min_x = i.x
		}
		if i.y < min_y {
			min_y = i.y
		}
		if i.x > max_x {
			max_x = i.x
		}
		if i.y > max_y {
			max_y = i.y
		}
	}
	width := max_x - min_x
	height := max_y - min_y
	return raylib.Rectangle{min_x, min_y, width, height}
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
	verts := building_to_vertices(b)
	return {{verts[0], verts[1], verts[2]}, {verts[2], verts[3], verts[0]}}
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
	w := b.width / 2
	h := b.height / 2
	points: [4]Vec2 = {{w, h}, {-w, h}, {-w, -h}, {w, -h}}
	for &i in points {
		i = raylib.Vector2Rotate(i, b.rotation) + b.center
	}
	return points
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
check_collision_buildings :: proc(a: Building, b: Building) -> bool {
	a1 := building_to_rectangle(a)
	b1 := building_to_rectangle(b)
	if !raylib.CheckCollisionRecs(a1, b1) {
		return false
	}
	t1 := building_to_triangles(a)
	t2 := building_to_triangles(b)
	v1 := building_to_vertices(a)
	v2 := building_to_vertices(b)
	for i in t1 {
		for j in v2 {
			if raylib.CheckCollisionPointTriangle(j, i[0], i[1], i[2]) {
				return true
			}
		}
	}
	for i in t2 {
		for j in v1 {
			if raylib.CheckCollisionPointTriangle(j, i[0], i[1], i[2]) {
				return true
			}
		}
	}
	for i in t1 {
		for j in 0 ..< 3 {
			for k in t2 {
				for l in 0 ..< 3 {
					s1 := i[j]
					e1 := i[(j + 1) % 3]
					s2 := k[l]
					e2 := k[(l + 1) % 3]
					if raylib.CheckCollisionLines(s1, e1, s2, e2, nil) {
						return true
					}
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
check_collision_building_circle :: proc(a: Building, center: Vec2, rad: f32) -> bool {
	rect := building_to_rectangle(a)
	if !raylib.CheckCollisionCircleRec(center, rad, rect) {
		return false
	}
	tris := building_to_triangles(a)
	quad := building_to_vertices(a)
	for i in tris {
		if raylib.CheckCollisionPointTriangle(center, i[0], i[1], i[2]) {
			return true
		}
	}
	for i in 0 ..< 4 {
		s := quad[i]
		e := quad[(i + 1) % 4]
		if raylib.CheckCollisionCircleLine(center, rad, s, e) {
			return true
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
check_collision_building_line :: proc(a: Building, start: Vec2, end: Vec2) -> bool {
	tris := building_to_triangles(a)
	quad := building_to_vertices(a)
	for i in tris {
		if raylib.CheckCollisionPointTriangle(start, i[0], i[1], i[2]) ||
		   raylib.CheckCollisionPointTriangle(end, i[0], i[1], i[2]) {
			return true
		}
	}
	for i in 0 ..< 4 {
		s1 := quad[i]
		e1 := quad[(i + 1) % 4]
		if raylib.CheckCollisionLines(s1, e1, start, end, nil) {
			return true
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
town_building_collides :: proc(this: ^Town, b: Building) -> bool {
	for i in this.buildings {
		if check_collision_buildings(i^, b) {
			return true
		}
	}
	for i in this.edges {
		if check_collision_building_line(b, i.start^, i.end^) {
			return true
		}
	}
	for i in this.water {
		if check_collision_building_circle(b, i.pos, i.radius) {
			return true
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
edge_start :: proc(e: Edge) -> Vec2 {
	return e.start^
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_end :: proc(e: Edge) -> Vec2 {
	return e.end^
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_forward :: proc(e: Edge) -> Vec2 {
	return linalg.normalize(edge_end(e) - edge_start(e))
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_length :: proc(e: Edge) -> f32 {
	return linalg.length(edge_end(e) - edge_start(e))
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_center :: proc(e: Edge) -> Vec2 {
	return (edge_start(e) + edge_end(e)) / 2
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_left :: proc(e: Edge) -> Vec2 {
	return raylib.Vector2Rotate(linalg.normalize(edge_end(e) - edge_start(e)), math.PI / 2)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_eq :: proc(e1: Edge, e2: Edge) -> bool {
	v1 := e1.start == e2.start && e1.end == e2.end
	v2 := e1.start == e2.end && e1.end == e2.start
	v3 := e1.start^ == e2.start^ && e1.end^ == e2.end^
	v4 := e1.start^ == e2.end^ && e1.end^ == e2.start^
	return v1 || v2 || v3 || v4
}


@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
edge_borders :: proc(e1: Edge, e2: Edge) -> bool {
	return e1.start == e2.start || e1.start == e2.end || e1.end == e2.start || e1.end == e2.end
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
	frd := edge_forward(e)
	return math.atan2(frd.y, frd.x)
}


town_min_distance_to_water :: proc(this: ^Town, point: Vec2) -> f32 {
	out: f32 = math.INF_F32
	for i in this.water {
		d := linalg.distance(i.pos, point)
		if d < out {
			out = d
		}
	}
	return out
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
dist_to_center :: proc(this: ^Town, point: Vec2) -> f32 {
	_ = this
	c := this.center
	return raylib.Vector2Distance(c, point)
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
delta_vector :: proc(this: ^Town, point: Vec2) -> Vec2 {
	center := this.center
	delta := point - center
	ln := linalg.length(delta)
	if ln == 0 {
		return {1, 0}
	}
	return delta / ln
}

@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
max_petal_vector :: proc(this: ^Town, point: Vec2) -> f32 {
	mx: f32 = -1
	dlt := delta_vector(this, point)
	for i in this.petals {
		dt := linalg.dot(dlt, i)
		os := math.sign(dt)
		dt = math.pow(dt, 5)
		dt *= os
		if dt > mx {
			mx = dt
		}
	}
	return mx
}
@(fast_math = {
	.Allow_Reassoc,
	.No_NaNs,
	.No_Infs,
	.No_Signed_Zeros,
	.Allow_Reciprocal,
	.Allow_Contract,
})
create_water :: proc(this: ^Town, shape: WaterShape, alloc: mem.Allocator) {
	NOISE_DIV :: 80
	NOISE_MUL :: 30
	LONG :: 40
	WATER_RAD :: 15
	context.allocator = alloc
	seed := rand.int63()
	fmt.printf("shape:%v\n", shape)
	this.allowed = {-this.width, -this.height, this.width * 2, this.height * 2}
	switch shape {
	case .RiverNorthSouth:
		this.center = {this.width / 2, this.height / 2}
		for i in -this.height / 5 ..< this.height / 5 {
			v := (noise.noise_2d(seed, {cast(f64)i / NOISE_DIV, 0}) - 0.5) * 2
			for dx in -3 ..= 3 {
				px := cast(f32)(cast(int)this.width / 2 + dx * 10 + 5) + v * NOISE_MUL
				py := (cast(f32)i) * 10
				p := new(WaterPoint, alloc)
				p.pos.x = px
				p.pos.y = py
				p.radius = WATER_RAD
				append(&this.water, p)
			}
		}
	case .RiverEastWest:
		for i in -this.width / 5 ..< this.width / 5 {
			this.center = {this.width / 2, this.height / 2}
			v := (noise.noise_2d(seed, {cast(f64)i / NOISE_DIV, 0}) - 0.5) * 2
			for dx in -3 ..= 3 {
				py := cast(f32)(cast(int)this.height / 2 + dx * 10 + 5) + v * NOISE_MUL
				px := (cast(f32)i) * 10
				p := new(WaterPoint, alloc)
				p.pos.x = px
				p.pos.y = py
				p.radius = WATER_RAD
				append(&this.water, p)
			}
		}
	case .CoastNorth:
		this.allowed.y = 0
		this.center = {this.width / 2, this.height / 3}
		for i in -this.width / 5 ..< this.width / 5 {
			v := (noise.noise_2d(seed, {cast(f64)i / NOISE_DIV, 0}) - 0.5) * 2
			for dx in -LONG ..= 10 {
				py := cast(f32)(dx * 10 + 5) + v * NOISE_MUL
				px := (cast(f32)i) * 10
				p := new(WaterPoint, alloc)
				p.pos.x = px
				p.pos.y = py
				p.radius = WATER_RAD
				append(&this.water, p)
			}
		}
	case .CoastSouth:
		this.center = {this.width / 2, this.height - this.height / 3}
		this.allowed.height = this.height - 10 * 10 - 5
		this.allowed.y = 0
		for i in -this.width / 5 ..< this.width / 5 {
			v := (noise.noise_2d(seed, {cast(f64)i / NOISE_DIV, 0}) - 0.5) * 2
			for dx in -10 ..= LONG {
				py := cast(f32)(dx * 10 + 5 + cast(int)this.height) + v * NOISE_MUL
				px := (cast(f32)i) * 10
				p := new(WaterPoint, alloc)
				p.pos.x = px
				p.pos.y = py
				p.radius = WATER_RAD
				append(&this.water, p)
			}
		}
	case .CoastEast:
		this.center = {this.width - this.width / 3, this.height / 2}
		this.allowed.width = this.width - 10 * 10 - 5
		for i in -this.width / 5 ..< this.width / 5 {
			v := (noise.noise_2d(seed, {cast(f64)i / NOISE_DIV, 0}) - 0.5) * 2
			for dx in -10 ..= LONG {
				py := cast(f32)(i * 10 + 5)
				px := (cast(f32)dx) * 10 + this.width + v * NOISE_MUL + 2
				p := new(WaterPoint, alloc)
				p.pos.x = px
				p.pos.y = py
				p.radius = WATER_RAD
				append(&this.water, p)
			}
		}
	case .CoastWest:
		this.center = {this.width / 3, this.height / 2}
		this.allowed.x = 0
		for i in -this.width / 5 ..< this.width / 5 {
			v := (noise.noise_2d(seed, {cast(f64)i / NOISE_DIV, 0}) - 0.5) * 2
			for dx in -LONG ..= 10 {
				py := cast(f32)(i * 10 + 5)
				px := (cast(f32)dx) * 10 + v * NOISE_MUL
				p := new(WaterPoint, alloc)
				p.pos.x = px
				p.pos.y = py
				p.radius = WATER_RAD
				append(&this.water, p)
			}
		}
	case .LakeCenter:
		this.center = {this.width / 2, this.height / 2}
		cx := this.width / 2
		cy := this.height / 2
		RAD :: 15
		for y in -RAD * 2 ..= RAD * 2 {
			for x in -RAD * 2 ..= RAD * 2 {
				dist := y * y + x * x
				if dist <
				   (RAD + 1) * (RAD + 1) +
					   cast(int)(noise.noise_2d(seed, {cast(f64)x / 10, cast(f64)y / 10}) * 100) {
					py := cast(f32)(y * 10) + cast(f32)cy
					px := cast(f32)(x * 10) + cast(f32)cx
					p := new(WaterPoint, alloc)
					p.pos.x = px
					p.pos.y = py
					p.radius = WATER_RAD
					append(&this.water, p)
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
create_points_and_edges :: proc(this: ^Town, alloc: mem.Allocator) {
	seed_x := rand.int63()
	seed_y := rand.int63()
	seed_x1 := rand.int63()
	seed_y1 := rand.int63()
	seed_x2 := rand.int63()
	seed_y2 := rand.int63()
	roads_x := make(map[i32]u8)
	roads_y := make(map[i32]u8)
	defer delete(roads_x)
	defer delete(roads_y)
	min_x := -cast(i32)this.width / TILE_SIZE
	max_x := cast(i32)this.width / TILE_SIZE * 2
	min_y := -cast(i32)this.height / TILE_SIZE
	max_y := cast(i32)this.height / TILE_SIZE * 2
	{
		DIVISOR :: 3
		x_road_count := (this.width * 3 / TILE_SIZE) / DIVISOR
		for i in 0 ..< x_road_count {
			tmp := min_x + cast(i32)i * DIVISOR + rand.int32_range(-1, 2)
			roads_x[tmp] = 1
		}
		y_road_count := (this.height * 3 / TILE_SIZE) / DIVISOR
		for i in 0 ..< y_road_count {
			tmp := min_y + cast(i32)i * DIVISOR + rand.int32_range(-1, 2)
			roads_y[tmp] = 1
		}
	}
	{
		reserve_map(&this.grid, (max_y - min_y + 1) * (max_x - min_y + 1))
	}
	for dy in min_y ..= max_y {
		for dx in min_x ..= max_x {
			p := Point{dx, dy}
			shift_x := (noise.noise_2d(seed_x, {cast(f64)dx / 20, cast(f64)dy / 20}) - 0.5) * 2 * 2
			shift_y := (noise.noise_2d(seed_y, {cast(f64)dx / 20, cast(f64)dy / 20}) - 0.5) * 2 * 2
			shift_x +=
				(noise.noise_2d(seed_x1, {cast(f64)dx / 10, cast(f64)dy / 10}) - 0.5) * 2 * 0.5
			shift_y +=
				(noise.noise_2d(seed_y1, {cast(f64)dx / 10, cast(f64)dy / 10}) - 0.5) * 2 * 0.5
			shift_x += (noise.noise_2d(seed_x2, {cast(f64)dx, cast(f64)dy}) - 0.5) * 2 * 0.25
			shift_y += (noise.noise_2d(seed_y2, {cast(f64)dx, cast(f64)dy}) - 0.5) * 2 * 0.25
			shift_x /= 2.75
			shift_y /= 2.75
			v := Vec2{cast(f32)dx * TILE_SIZE, cast(f32)dy * TILE_SIZE}
			dist := 1 - math.sqrt(linalg.length(v - this.center) / (this.width / 2))
			v += Vec2{shift_x, shift_y} * 10 * dist
			p0 := new_clone(v, alloc)
			append(&this.points, p0)
			this.grid[p] = p0
		}
	}
	{
		base_theta := rand.float32() * 2 * math.PI
		cx := this.center
		seed := rand.int63()
		for i in this.points {
			dx := i^ - cx
			dist := 1 - math.sqrt(linalg.length(dx) / (this.width / 2))
			dist *= dist
			p0 := raylib.Vector2Rotate(
				dx,
				base_theta +
				(noise.noise_2d(
							seed,
							cast([2]f64)(Vec2 {
									math.atan2(dx.y, dx.x) * 80,
									linalg.length(dx) / 400,
								}),
						) -
						0.5) /
					2 *
					1 *
					dist,
			)
			i^ = p0 + cx
		}
	}
	for dy in -cast(i32)this.height / TILE_SIZE ..= cast(i32)this.height / TILE_SIZE * 2 {
		for dx in -cast(i32)this.width / TILE_SIZE ..= cast(i32)this.width / TILE_SIZE * 2 {
			point := Point{dx, dy}
			point2 := Point{dx + 1, dy}
			point3 := Point{dx, dy + 1}
			p0 := this.grid[point]
			w_base: f32 = ROAD_WIDTH
			w_max: f32 = LARGE_ROAD_WIDTH
			if point2 in this.grid {
				is_road := dy in roads_x
				p1 := this.grid[point2]
				start := p0^
				end := p1^
				/*hit := !(raylib.CheckCollisionPointRec(start, this.allowed) &&
					raylib.CheckCollisionPointRec(end, this.allowed))*/
				hit := false
				if !hit {
					for i in this.water {
						if raylib.CheckCollisionCircleLine(i.pos, i.radius, start, end) {
							hit = true
							break
						}
					}
				}
				ed := new_clone(Edge{p0, p1, w_max if is_road else w_base, hit}, alloc)
				append(&this.edges, ed)
			}
			if point3 in this.grid {
				is_road := dx in roads_x
				p2 := this.grid[point3]
				start := p0^
				end := p2^
				/*	hit := !(raylib.CheckCollisionPointRec(start, this.allowed) &&
					raylib.CheckCollisionPointRec(end, this.allowed))*/
				hit := false
				if !hit {
					for i in this.water {
						if raylib.CheckCollisionCircleLine(i.pos, i.radius, start, end) {
							hit = true
							break
						}
					}
				}
				ed := new_clone(Edge{p0, p2, w_max if is_road else w_base, hit}, alloc)
				append(&this.edges, ed)

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
point_weighted_distance :: proc(this: ^Town, point: Vec2) -> f32 {
	return(
		town_min_distance_to_water(this, point) / 4 +
		dist_to_center(this, point) * 3 -
		max_petal_vector(this, point) * 1000 \
	)
}

create_buildings :: proc(this: ^Town, building_count: int, alloc: mem.Allocator) {
	alive_edges := make([dynamic]^Edge)
	reserve(&alive_edges, len(this.edges))
	for i in this.edges {
		if !i.is_ghost {
			append(&alive_edges, i)
		}
	}
	defer delete(alive_edges)
	sorted_edges := alive_edges[:]
	context.user_ptr = this
	sort.quick_sort_proc(sorted_edges, proc(x: ^Edge, y: ^Edge) -> int {
		s1 := edge_center(x^)
		s2 := edge_center(y^)
		this := cast(^Town)context.user_ptr
		d1 := point_weighted_distance(this, s1)
		d2 := point_weighted_distance(this, s2)
		return sort.compare_f32s(d1, d2)
	})
	outer: for i in sorted_edges {
		start := edge_start(i^)
		frd := edge_forward(i^)
		lft := edge_left(i^)
		ln := edge_length(i^)
		rt := edge_rotation(i^)
		sign: f32 = 1
		SHIFT := i.width
		for _i in 0 ..= 1 {
			dy: f32 = 0
			for dy < ln {
				p_large := 1 - dist_to_center(this, start) / (this.width / 2)
				p_large = p_large
				width := cast(f32)rand.int32_range(7, 15)
				height := cast(f32)rand.int32_range(8, 22)
				if rand.float32() < math.pow(p_large, 3.5) {
					width = cast(f32)rand.int32_range(15, 20)
					height = cast(f32)rand.int32_range(15, 40)
				}
				pos := start + frd * (dy + width / 2) + lft * (height / 2 + SHIFT) * sign
				b: Building
				b.height = height
				b.width = width
				b.rotation = rt
				b.center = pos
				if !town_building_collides(this, b) {
					b2 := new_clone(b, alloc)
					append(&this.buildings, b2)
					dy += width
				} else {
					dy += 1
				}
				if len(this.buildings) > building_count {
					break outer
				}
			}
			sign *= -1
		}

	}
}


create_walls :: proc(this: ^Town, age: f32) {
	max_rad: f32 = 0.
	if len(this.buildings) < 1 {
		return
	}
	center := Vec2{}
	building_count := cast(f32)len(this.buildings)
	for i in this.buildings {
		center += i.center
	}
	center /= building_count
	stddev: f32 = 0.0
	for i in this.buildings {
		dist := linalg.distance(i.center, center)
		stddev += dist * dist
		if dist > max_rad {
			max_rad = dist
		}
	}
	if building_count < 2 {
		building_count = 2
	}
	stddev /= (building_count - 1)
	stddev = math.sqrt(stddev)
	radius := stddev * (age) + max_rad * (1 - age)
	theta: f32 = 0.0
	current: ^Vec2 = nil
	guess: Vec2 = Vec2{math.cos(theta), math.sin(theta)} * radius + center
	prev: Vec2 = Vec2{math.cos(theta - 0.1), math.sin(theta - 0.1)} * radius + center
	prev0: Vec2 = Vec2{math.cos(theta - 0.2), math.sin(theta - 0.2)} * radius + center
	closest_distance: f32 = 0
	for i in this.points {
		delta := linalg.normalize(prev - prev0)
		delta_2 := linalg.normalize(i^ - prev)
		if linalg.dot(delta, delta_2) < 0.5 {
			continue
		}
		dist := linalg.distance(i^, guess)
		if dist < closest_distance || current == nil {
			current = i
			closest_distance = dist
		}
	}
	start := current
	for theta < math.TAU {
		guess = Vec2{math.cos(theta), math.sin(theta)} * radius + center
		closest_distance = linalg.distance(guess, current^)
		is_ghost: bool = false
		next: ^Vec2 = nil
		for i in this.edges {
			second: ^Vec2 = nil
			if (i.start == current && i.end == current) {
				continue
			}
			if i.start == current {
				second = i.end
			}
			if i.end == current {
				second = i.start
			}
			if second == nil {
				continue
			}
			delta := linalg.normalize(current^ - prev)
			delta2 := linalg.normalize(second^ - current^)
			if linalg.dot(delta, delta2) < -0.5 {
				continue
			}
			dist := linalg.distance(guess, second^)
			if dist < closest_distance {
				is_ghost = i.is_ghost
				next = second
				closest_distance = dist
			}
			if theta > math.TAU * 0.9 {
				if second == start {
					closest_distance = 0
					is_ghost = i.is_ghost
					next = second
					closest_distance = dist
				}
			}
		}
		if next != nil {
			append(&this.walls, Wall{current, next, is_ghost})
			prev = current^
			current = next
		}
		theta += 0.01
	}
}

create_town :: proc(
	water_shape: WaterShape,
	building_count: int,
	age: f32,
	alloc: mem.Allocator,
) -> ^Town {
	this := new(Town, alloc)
	this.width = math.ceil(cast(f32)math.sqrt(cast(f32)building_count) * 30)
	this.height = math.ceil(cast(f32)math.sqrt(cast(f32)building_count) * 30)
	{
		this.grid = make(map[Point]^Vec2, alloc)
		this.water = make([dynamic]^WaterPoint, alloc)
		this.points = make([dynamic]^Vec2, alloc)
		this.edges = make([dynamic]^Edge, alloc)
		this.buildings = make([dynamic]^Building, alloc)
		this.petals = make([dynamic]Vec2, alloc)
		this.walls = make([dynamic]Wall, alloc)
	}
	{
		count := rand.int32_range(3, 5)
		base := rand.float32() * math.PI * 2
		for i in 0 ..= count {
			v := (rand.float32() - 0.5) + base + cast(f32)i / (cast(f32)count) * math.PI * 2
			pt := Vec2{math.cos(v), math.sin(v)}
			append(&this.petals, pt)
		}
	}
	create_water(this, water_shape, alloc)
	create_points_and_edges(this, alloc)
	create_buildings(this, building_count, alloc)
	create_walls(this, age)
	return this
}

random_water :: proc() -> WaterShape {
	v := rand.int_range(0, 7)
	if v == 0 {
		return .RiverNorthSouth
	} else if v == 1 {
		return .RiverEastWest
	} else if v == 2 {
		return .CoastNorth
	} else if v == 3 {
		return .CoastSouth
	} else if v == 4 {
		return .CoastEast
	} else if v == 5 {
		return .CoastWest
	} else if v == 6 {
		return .LakeCenter
	}
	return .LakeCenter
}

town_render2d :: proc(this: ^Town, path: string) {
	min_x: i32 = 0
	min_y: i32 = 0
	hit := false
	max_x: i32 = 0
	max_y: i32 = 0
	for i in this.buildings {
		if !hit {
			min_x = cast(i32)i.center.x
			min_y = cast(i32)i.center.y
			max_x = min_x
			max_y = min_y
		}
		hit = true
		x := cast(i32)i.center.x
		y := cast(i32)i.center.y
		if x < min_x {
			min_x = x
		}
		if y < min_y {
			min_y = y
		}
		if x > max_x {
			max_x = x
		}
		if y > max_y {
			max_y = y
		}
	}
	for i in this.walls {
		if i.is_ghost {
			continue
		}
		hit = true
		if cast(i32)i.start.x < min_x {
			min_x = cast(i32)i.start.x
		}
		if cast(i32)i.start.y < min_y {
			min_y = cast(i32)i.start.y
		}
		if cast(i32)i.start.x > max_x {
			max_x = cast(i32)i.start.x
		}
		if cast(i32)i.start.y > max_y {
			max_y = cast(i32)i.start.y
		}
		if cast(i32)i.end.x < min_x {
			min_x = cast(i32)i.end.x
		}
		if cast(i32)i.end.y < min_y {
			min_y = cast(i32)i.end.y
		}
		if cast(i32)i.end.x > max_x {
			max_x = cast(i32)i.end.x
		}
		if cast(i32)i.end.y > max_y {
			max_y = cast(i32)i.end.y
		}
	}
	if !hit {
		min_x = 0
		min_y = 0
		max_x = cast(i32)this.width
		max_y = cast(i32)this.height
	} else {
		min_x -= TILE_SIZE * 2
		min_y -= TILE_SIZE * 2
		max_x += TILE_SIZE * 2
		max_y += TILE_SIZE * 2
	}
	width := max_x - min_x
	height := max_y - min_y
	shift := Vec2{cast(f32)min_x, cast(f32)min_y}
	img := raylib.GenImageColor(width, height, raylib.WHITE)
	defer raylib.UnloadImage(img)

	for i in this.water {
		raylib.ImageDrawCircleV(&img, i.pos - shift, cast(i32)i.radius, raylib.GRAY)
	}
	for i in this.buildings {
		tmp := i^
		tmp.height -= 1
		tmp.width -= 1
		tmp.center -= shift
		qd := building_to_vertices(tmp)
		for j in 0 ..< 4 {
			raylib.ImageDrawLineV(&img, qd[j], qd[(j + 1) % 4], raylib.BLACK)
		}
	}
	for i in this.walls {
		if !i.is_ghost {
			raylib.ImageDrawLineEx(&img, i.start^ - shift, i.end^ - shift, 4, raylib.DARKGRAY)
		}
	}
	cstr_path := strings.clone_to_cstring(path)
	defer delete(cstr_path)
	raylib.ExportImage(img, cstr_path)
}
