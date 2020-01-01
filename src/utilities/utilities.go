package utilities

import "gido.vn/gic/libs/common.git/l"

var (
	ll = l.New()
)

// HandleError ...
func HandleError(err error, msg string) {
	if err != nil {
		ll.Error("Error: "+msg, l.Error(err))
	}
}

// HandlePanic ...
func HandlePanic(err error, msg string) {
	if err != nil {
		ll.Panic("Error: "+msg, l.Error(err))
	}
}
