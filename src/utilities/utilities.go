package utilities

import (
	"fmt"
	"regexp"
	"strings"

	"gido.vn/gic/databases/sqitch.git/src/models"
	"gido.vn/gic/libs/common.git/l"
)

var (
	ll = l.New()
)

func main() {

}

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

// GenFieldTag ...
func GenFieldTag(d *models.ModelField) string {
	if d.Type == "timestamptz" || d.Type == "timestamp" {
		return "`json:\"" + d.Name + ",omitempty\" gorm:\"" + d.Gorm + "column:" + d.Name + ";type:" + d.Type + "\"`"
	}

	return "`json:\"" + d.Name + ",omitempty\" gorm:\"" + d.Gorm + "column:" + d.Name + "\"`"
}

// ConvertGoTypeToDbType ...
func ConvertGoTypeToDbType(str string) string {
	if str == "time" {
		return "*postgres.Time"
	}
	return str
}

// ToSnakeCase ...
func ToSnakeCase(str string) string {
	var matchFirstCap = regexp.MustCompile("(.)([A-Z][a-z]+)")
	var matchAllCap = regexp.MustCompile("([a-z0-9])([A-Z])")
	snake := matchFirstCap.ReplaceAllString(str, "${1}_${2}")
	snake = matchAllCap.ReplaceAllString(snake, "${1}_${2}")
	return strings.ToLower(snake)
}

// TitleMany ...
func TitleMany(str string) string {
	s := ToCamel(str)
	if len(s) == 0 {
		return s
	}
	if s[len(s)-1:] == "y" {
		s = s[:len(s)-1] + "ies"
	} else if s[len(s)-1:] == "s" || s[len(s)-1:] == "x" {
		s = s + "es"
	} else {
		s = s + "s"
	}
	return s
}

// ToProtoField ...
func ToProtoField(d *models.ModelField, varName string) string {
	upperCamelCaseName := ToCamelGolangCase(d.Name)
	switch d.GoType {
	case "string", "text", "bool", "stringArray", "jsonb":
		return varName + "." + upperCamelCaseName
	case "int", "enum":
		return "int32(" + varName + "." + upperCamelCaseName + ")"
	case "int64":
		return "int64(" + varName + "." + upperCamelCaseName + ")"
	case "float":
		return "float32(" + varName + "." + upperCamelCaseName + ")"
	case "float64":
		return "float64(" + varName + "." + upperCamelCaseName + ")"
	case "time":
		return "common.MillisP((*time.Time)(" + varName + "." + upperCamelCaseName + "))"
	default:
		return varName + "." + upperCamelCaseName
	}
}

// ToTitleNorm ...
func ToTitleNorm(input string) string {
	var output []byte
	var upperCount int
	for i, c := range input {
		switch {
		case c >= 'A' && c <= 'Z':
			if upperCount == 0 || nextIsLower(input, i) {
				if upperCount == 1 && nextIsLower(input, i) {
					output = append(output, byte(c-'A'+'a'))
				} else {
					output = append(output, byte(c))
				}
			} else {
				output = append(output, byte(c-'A'+'a'))
			}
			upperCount++

		case c >= 'a' && c <= 'z':
			output = append(output, byte(c))
			upperCount = 0

		case c >= '0' && c <= '9':
			if i == 0 {
				ll.Panic("Identifier must start with a character", l.String("ident", input))
			}
			output = append(output, byte(c))
			upperCount = 0
		}
	}
	return string(output)
}

func nextIsLower(input string, i int) bool {
	return i+1 < len(input) && input[i+1] >= 'a' && input[i+1] <= 'z'
}

// ToCamelGolangCase ...
func ToCamelGolangCase(str string) string {
	arrStr := strings.Split(str, "_")

	var convertedStr string
	for index, s := range arrStr {
		word := s
		if (index == 0 || index == len(arrStr)-1) && len(word) == 2 {
			allowUpper := map[string]string{"id": "ID"}
			if allowUpper[word] != "" {
				word = strings.ToUpper(word)
			}
		}

		word = ToCamel(word)
		convertedStr += word
	}

	return convertedStr
}

// DetectChanges ...
func DetectChanges(field models.Field) []string {
	var changes []string

	if field.IsNewField {
		changes = append(changes, fmt.Sprintf("new field"))
	}
	if field.OldName != "" {
		changes = append(changes, fmt.Sprintf("name: %v to %v\n", field.OldName, field.Name))
	}
	if field.IsTypeChanged {
		changes = append(changes, fmt.Sprintf("type: to %v\n", field.Type))
	}
	if field.IsPrimaryChanged {
		changes = append(changes, fmt.Sprintf("primary: %v to %v\n", !field.Primary, field.Primary))
	}
	if field.IsNotNullChanged {
		changes = append(changes, fmt.Sprintf("not_null: %v to %v\n", !field.NotNull, field.NotNull))
	}
	if field.IsUniqueChanged {
		changes = append(changes, fmt.Sprintf("unique: %v to %v\n", !field.Unique, field.Unique))
	}
	if field.IsDefaultChanged {
		changes = append(changes, fmt.Sprintf("default: to %v\n", field.Default))
	}

	return changes
}

