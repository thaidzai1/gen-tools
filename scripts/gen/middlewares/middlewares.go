package middlewares

import (
	"gido.vn/gic/libs/common.git/l"
	"gido.vn/gic/databases/sqitch.git/scripts/gen/models"
)

var (
	ll = l.New()
)

// GenerateSQL ...
func GenerateSQL(validate interface{}, next interface{}, data interface{}) {
	flagPassMiddleware := true
	if flagPassMiddleware {
		ll.Info("==> Pass middleware load yaml")
		switch next.(type) {
		case func(*models.MigrateSchema):
			next.(func(*models.MigrateSchema))(data.(*models.MigrateSchema))
		default:
			break
		}
	}
}
