package gen

import (
	"strings"
	"text/template"
)

type Template struct {
	*template.Template
}

func Parse(s string) Template {
	s = strings.Replace(s, "$:", "$.Extra.", -1)
	return Template{template.Must(template.New("model").Parse(s))}
}

func (t Template) Link(name, s string) Template {
	s = strings.Replace(s, "$.", "$._.", -1)
	s = strings.Replace(s, "$:", "$._.Extra.", -1)
	template.Must(t.Template.New(name).Parse(s))
	return t
}
