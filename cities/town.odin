package cities
import "core:math"
import "core:math/rand"
import "core:mem"
import "vendor:raylib"
Vec2 :: raylib.Vector2
Point :: struct {
	x: i32,
	y: i32,
}

Edge :: struct {
	start: ^Point,
	end:   ^Point,
}

OwnedEdge :: struct {
	start: Point,
	end:   Point,
}

Building :: struct {
	center: Point,
	width:  i32,
	height: i32,
}

Town :: struct {
	points: [dynamic]^Point,
	edges:  [dynamic]^Edge,
}

point_to_vec2 :: proc(p: Point) -> Vec2 {
	return Vec2{cast(f32)p.x, cast(f32)p.y}
}

vec2_to_point :: proc(v: Vec2) -> Point {return Point{cast(i32)v.x, cast(i32)v.y}}

point_distance_to_point :: proc(p1: Point, p2: Point) -> f32 {
	dx := cast(f32)(p1.x - p2.x)
	dy := cast(f32)(p1.y - p2.y)
	return math.sqrt(dx * dx + dy * dy)
}

distance_to_edge :: proc(p: Point, e: OwnedEdge) -> f32 {
	p0 := point_to_vec2(p)
	s := point_to_vec2(e.start)
	e := point_to_vec2(e.end)
	l := raylib.Vector2Distance(s, e)
	d := math.ceil(l)
	min_dist := raylib.Vector2DistanceSqr(p0, s)
	if l == 0 {
		return min_dist
	}
	for i in 0 ..= cast(i32)d {
		t := cast(f32)i / l
		p_prime := s * (1 - t) + e * t
		dist := raylib.Vector2DistanceSqr(p0, p_prime)
		if dist < min_dist {
			min_dist = dist
		}
	}
	return min_dist
}


distance_between_edges :: proc(e1: OwnedEdge, e2: OwnedEdge) -> f32 {
	s := point_to_vec2(e1.start)
	e := point_to_vec2(e1.end)
	l := raylib.Vector2Distance(s, e)
	d := math.ceil(l)
	min_dist := distance_to_edge(e1.start, e2)
	for i in 0 ..= cast(i32)d {
		t := cast(f32)i / l
		p_prime := vec2_to_point(s * (1 - t) + e * t)
		d := distance_to_edge(p_prime, e2)
		if d < min_dist {
			min_dist = d
		}
	}
	return min_dist
}

town_has_edge :: proc(this: ^Town, e: Edge) -> bool {
	for i in this.edges {
		if (i.end == e.end && i.start == e.start) || (i.start == e.end && i.end == e.start) {
			return true
		}
	}
	return false
}

rand_point :: proc() -> Point {
	return {rand.int32_range(0, 1000), rand.int32_range(0, 1000)}
}

create_town :: proc(alloc: mem.Allocator, building_count: int) -> ^Town {
	context.allocator = alloc
	this := new(Town)
	this.edges = make([dynamic]^Edge)
	this.points = make([dynamic]^Point)
	reserve(&this.points, 1000)
	for i in 0 ..< 1000 {
		append(&this.points, new_clone(rand_point()))
	}
	for &i, idx in this.points {
		for &j, idx2 in this.points {
			if idx == idx {
				continue
			}
			ed := Edge{i, j}
			if point_distance_to_point(i^, j^) < 100 {
				if !town_has_edge(this, ed) {
					append(&this.edges, new_clone(ed))
				}
			}
		}
	}
	dbg := raylib.GenImageColor(1000, 1000, raylib.WHITE)
	defer raylib.UnloadImage(dbg)
	for i in this.edges {
		raylib.ImageDrawLine(&dbg, i.start.x, i.start.y, i.end.x, i.end.y, raylib.BLACK)
	}
	for i in this.points {
		raylib.ImageDrawCircle(&dbg, i.x, i.y, 3, raylib.RED)
	}
	raylib.ExportImage(dbg, "test.png")
	return this
}
