package utils

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:reflect"
import "core:strings"

import "core:math/rand"
import "vendor:raylib"
TEXT_HEIGHT_MIN :: 10
TEXT_HEIGHT_MAX :: 20
choice :: proc(list: []$T) -> T {
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

OwnedPtr :: struct($T: typeid) {
	data:       ^T,
	allocator:  mem.Allocator,
	destructor: #type proc(this: ^T),
}

OwnedSlice :: struct($T: typeid) {
	data:       []T,
	allocator:  mem.Allocator,
	destructor: #type proc(this: ^T),
}

OwnedString :: struct {
	data:      string,
	allocator: mem.Allocator,
}

@(private = "file")
op_new_owned_ptr :: proc(
	$T: typeid,
	destructor: proc(this: ^T) = nil,
	allocator := context.allocator,
) -> OwnedPtr(T) {
	return OwnedPtr(T){data = new(T, allocator), allocator = allocator, destructor = destructor}
}

@(private = "file")
op_new_owned_slice :: proc(
	$L: typeid/[]$T,
	count: int,
	destructor: proc(this: ^T) = nil,
	allocator := context.allocator,
) -> OwnedSlice(T) {
	return OwnedSlice(T) {
		data = make_slice([]T, count, allocator),
		allocator = allocator,
		destructor = destructor,
	}
}


@(private = "file")
op_new_owned_string :: proc(v: string, allocator := context.allocator) -> OwnedString {
	return OwnedString{data = strings.clone(v, allocator), allocator = allocator}
}


@(private = "file")
op_new_owned_ptr_clone :: proc(
	v: $T,
	destructor: proc(this: ^T) = nil,
	allocator := context.allocator,
) -> OwnedPtr(T) {
	return OwnedPtr(T) {
		data = new_clone(v, allocator),
		allocator = allocator,
		destructor = destructor,
	}
}

@(private = "file")
op_new_owned_slice_clone :: proc(
	list: []$T,
	destructor: proc(this: ^T) = nil,
	allocator := context.allocator,
) -> OwnedSlice(T) {
	data := make_slice([]T, len(list), allocator)
	for i, idx in list {
		data[idx] = i
	}
	return OwnedSlice(T){data = data, allocator = allocator, destructor = destructor}
}

@(private = "file")
op_new_owned_string_typed :: proc(
	$T: typeid,
	v: string,
	allocator := context.allocator,
) where ($T == string)->OwnedString {
	return OwnedString{data = strings.clone(v, allocator), allocator = allocator}
}


@(private = "file")
op_new_owned_ptr_clone_typed :: proc(
	$T: typeid,
	v: T,
	destructor: proc(this: ^T) = nil,
	allocator := context.allocator,
) -> OwnedPtr(T) {
	return OwnedPtr(T) {
		data = new_clone(v, allocator),
		allocator = allocator,
		destructor = destructor,
	}
}


/*
op_new :: proc {
	op_new_owned_ptr,
	op_new_owned_ptr_clone,
	op_new_owned_ptr_clone_typed,
	op_new_owned_string,
	op_new_owned_string_typed,
}*/

op_new_slice :: proc {
	op_new_owned_slice,
	op_new_owned_slice_clone,
}

@(private = "file")
op_delete_owned_ptr :: proc(this: OwnedPtr($T)) {
	if this.data == nil {
		return
	}
	if this.destructor != nil {
		this.destructor(this.data)
	}
	free(this.data, this.allocator)
}

@(private = "file")
op_delete_owned_slice :: proc(this: OwnedSlice($T)) {
	if this.data == nil {
		return
	}
	if this.destructor != nil {
		for &i in this.data {
			this.destructor(&i)
		}
	}
	delete(this.data, this.allocator)
}

@(private = "file")
op_delete_owned_string :: proc(this: OwnedString) {
	delete(this.data, this.allocator)
}

/*
op_delete :: proc {
	op_delete_owned_ptr,
	op_delete_owned_slice,
	op_delete_owned_string,
}*/

ErrString :: struct {
	is_static: bool,
	content:   string,
	allocator: mem.Allocator,
	at:        runtime.Source_Code_Location,
}

ErrEnum :: struct {
	type: typeid,
	v:    int,
	at:   runtime.Source_Code_Location,
}

ErrAny :: struct {
	type:       typeid,
	ptr:        rawptr,
	destructor: proc(ptr: rawptr),
	allocator:  mem.Allocator,
	at:         runtime.Source_Code_Location,
}

ErrInt :: struct {
	v:  int,
	at: runtime.Source_Code_Location,
}

ErrNotOk :: struct {
	at: runtime.Source_Code_Location,
}

Err :: union {
	ErrInt,
	ErrEnum,
	ErrString,
	ErrAny,
	ErrNotOk,
}


@(private = "file")
err_enum :: proc(v: $T, loc := #caller_location) -> Err where intrinsics.type_is_enum(T) {
	value, b := reflect.as_int(v)
	assert(b)
	if value == 0 {
		return nil
	}
	return ErrEnum{type = T, v = value, at = loc}
}

@(private = "file")
err_int :: proc(v: $T, loc := #caller_location) -> Err where intrinsics.type_is_integer(T) {
	value := cast(int)v
	if value == 0 {
		return nil
	}
	return ErrInt{value, at = loc}
}

@(private = "file")
err_static_str :: proc($v: string, loc := #caller_location) -> Err {
	if v == "" {
		return nil
	}
	return ErrString{is_static = true, content = v, allocator = {}, at = loc}
}

@(private = "file")
err_str :: proc(v: string, allocator := context.allocator, loc := #caller_location) -> Err {
	if v == "" {
		return nil
	}
	return ErrString{is_static = false, content = v, allocator = allocator, at = loc}
}

@(private = "file")
err_any :: proc(
	v: $T,
	destructor: proc(ptr: ^T) = nil,
	allocator := context.allocator,
	loc := #caller_location,
) -> Err where !(intrinsics.is_enum(T) ||
		intrinsics.type_is_integer(T) ||
		intrinsics.type_is_string(T) ||
		intrinsics.type_is_boolean(T) ||
		T == Err) {
	when intrinsics.type_has_nil(T) {
		if reflect.is_nil(v) {
			return nil
		}
	}
	dest := cast(proc(ptr: rawptr))destructor
	ptr := new_clone(v, allocator)
	return ErrAny{type = T, ptr, dest, allocator, at = loc}
}

@(private = "file")
err_nil :: proc() -> Err {
	return nil
}


@(private = "file")
err_not_ok :: proc(b: bool, loc := #caller_location) -> Err {
	if b {
		return nil
	} else {
		return ErrNotOk{loc}
	}
}
@(private = "file")
err_err :: proc(e: Err, loc := #caller_location) -> Err {
	return e
}

err :: proc {
	err_any,
	err_enum,
	err_int,
	err_nil,
	err_static_str,
	err_str,
	err_not_ok,
	err_err,
}


delete_err :: proc(v: Err) {
	switch v in v {
	case nil:
		return
	case ErrInt:
		return
	case ErrEnum:
		return
	case ErrString:
		if !v.is_static {
			delete(v.content, v.allocator)
		}
	case ErrNotOk:
		return
	case ErrAny:
		if v.destructor != nil {
			v.destructor(v.ptr)
		}
		free(v.ptr, v.allocator)
	}

}

err_to_string :: proc(v: Err, allocator := context.temp_allocator) -> string {
	v := v
	switch &v in v {
	case nil:
		{
			return strings.clone("nil", allocator)
		}
	case ErrString:
		{
			return fmt.aprintf("Error:%s\n\tat %v", v.content, v.at, allocator = allocator)
		}
	case ErrInt:
		{
			return fmt.aprintf("Error:%d\n\tat %v", v.v, v.at, allocator = allocator)
		}
	case ErrNotOk:
		{
			return fmt.aprintf("Error:Not OK\n\tat %v", v.at, allocator = allocator)
		}
	case ErrEnum:
		{
			v0: any
			v0.data = &v.v
			v0.id = v.type
			return fmt.aprintf("Error:%v.%v\n\tat %v", v.type, v0, v.at, allocator = allocator)
		}
	case ErrAny:
		{
			v0: any
			v0.data = v.ptr
			v0.id = v.type
			return fmt.aprintf("Error:%v\n\tat %v", v0, v.at, allocator = allocator)
		}
	}

	return strings.clone("", allocator)
}

map_err_to_err :: proc(v: Err) -> (Err, bool) {
	#partial switch v in v {
	case nil:
		return nil, true
	case:
		return v, false
	}
}

try :: proc(v: $T, e: $E, loc := #caller_location) -> (T, Err) {
	et := err(e, loc = loc)
	return v, et
}

roll_dice :: proc(count: int, d: int) -> int {
	assert(d > 0 && count > 0)
	out := 0
	for i in 0 ..< count {
		out += rand.int_range(1, d + 1)
	}
	return out
}

catch :: proc(v: Err) -> bool {
	if v != nil {
		delete_err(v)
		return false
	} else {
		return true
	}
}
try_catch :: proc(v: $T, e: Err) -> (T, bool) {
	return v, catch(e)
}

ArenaHandle :: struct {
	_inner: ^mem.Dynamic_Arena,
	_alloc: mem.Allocator,
}

create_arena :: proc() -> (mem.Allocator, ArenaHandle) {
	base := new(mem.Dynamic_Arena)
	mem.dynamic_arena_init(base)
	return mem.dynamic_arena_allocator(base), ArenaHandle{base, context.allocator}
}

destroy_arena :: proc(arena: ArenaHandle) {
	mem.dynamic_arena_destroy(arena._inner)
	free(arena._inner, arena._alloc)
}
