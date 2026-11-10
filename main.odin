package libdnd
import "core:fmt"
import "core:io"
TError :: enum {
	None = 0,
	Gay,
}
failure :: proc() -> (int, io.Error) {
	return 0, io.Error.EOF
}

trys :: proc() -> Err {
	x := try(failure()) or_return
	return nil
}
main :: proc() {
	_, x := try(0, trys())
	fmt.printf("%v:sizeof:%d\n", typeid_of(ErrAny), size_of(ErrAny))
	fmt.printf("%v:sizeof:%d\n", typeid_of(ErrInt), size_of(ErrInt))
	fmt.printf("%v:sizeof:%d\n", typeid_of(ErrString), size_of(ErrString))
	fmt.printf("%v:sizeof:%d\n", typeid_of(ErrEnum), size_of(ErrEnum))
	fmt.printf("%v:sizeof:%d\n", typeid_of(ErrNotOk), size_of(ErrNotOk))
	fmt.printf("%s\n", err_to_string(x))
}
