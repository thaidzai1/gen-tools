package utilities

import (
	"regexp"
	"strings"

	"gido.vn/gic/libs/common.git/l"
)

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

// ToCamel ...
func ToCamel(str string) string {
	var link = regexp.MustCompile("(^[A-Za-z])|_([A-Za-z])")
	return link.ReplaceAllStringFunc(str, func(s string) string {
		return strings.ToUpper(strings.Replace(s, "_", "", -1))
	})
}
