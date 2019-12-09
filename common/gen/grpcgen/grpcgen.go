package grpcgen

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"sort"

	"gicprime.com/sqitch/common/gen"
)

var basePath = gen.ProjectPath()

// Method ...
type Method struct {
	Name       string
	InputType  string
	OutputType string
}

// Result ...
type Result struct {
	Services []*Service
	Imports  []Import
}

// Service ...
type Service struct {
	Name       string
	MapMethods map[string]Method
	Methods    []Method
}

// Import ...
type Import struct {
	Full string
	Name string
	Path string
}

// ParseServiceFile ...
func ParseServiceFile(inputPath string, interfaceNames ...string) Result {
	p := newParser()
	return p.parse(inputPath, interfaceNames...)
}

type sortMethodsType []Method

func (a sortMethodsType) Len() int           { return len(a) }
func (a sortMethodsType) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a sortMethodsType) Less(i, j int) bool { return a[i].Name < a[j].Name }

// SortMethods ...
func SortMethods(methods map[string]Method) []Method {
	sortMethods := make(sortMethodsType, 0, len(methods))
	for _, m := range methods {
		sortMethods = append(sortMethods, m)
	}
	sort.Sort(sortMethods)
	return sortMethods
}

type parserStruct struct {
	inputFilePath   string
	serviceNames    []string
	mapServiceNames map[string]bool

	fset *token.FileSet
}

func newParser() *parserStruct {
	return &parserStruct{
		fset: token.NewFileSet(),
	}
}

// inputPath is relative to basePath
func (p *parserStruct) parse(inputPath string, serviceNames ...string) Result {
	absPath := gen.GetAbsPath(inputPath)
	f, err := parser.ParseFile(p.fset, absPath, nil, 0)
	if err != nil {
		p.Fatalf("Unable to parse file `%v`.\n  Error: %v\n", absPath, err)
		return Result{}
	}

	p.inputFilePath = inputPath
	p.serviceNames = serviceNames
	p.mapServiceNames = make(map[string]bool)
	for _, name := range serviceNames {
		p.mapServiceNames[name] = false
	}

	return Result{
		Services: p.extract(f),
		Imports:  extractImports(f.Imports),
	}
}

func (p *parserStruct) extract(f *ast.File) (services []*Service) {
	var s *Service
	inspectFunc := func(node ast.Node) bool {
		switch node := node.(type) {
		case *ast.TypeSpec:
			if _, ok := p.mapServiceNames[node.Name.Name]; !ok {
				return false
			}
			p.mapServiceNames[node.Name.Name] = true

			s = &Service{
				Name: node.Name.Name,
			}
			services = append(services, s)

			switch typ := node.Type.(type) {
			case *ast.InterfaceType:
				s.MapMethods = p.extractMethods(typ)
				s.Methods = SortMethods(s.MapMethods)
				return false

			default:
				p.Fatalf("Error: %v must be an interface\n", s.Name)
			}
		}
		return true
	}

	ast.Inspect(f, inspectFunc)

	ok := true
	for name, found := range p.mapServiceNames {
		if !found {
			fmt.Printf("Error: interface name `%v` not found\n", name)
			ok = false
		}
		if !ok {
			os.Exit(1)
		}
	}
	return services
}

func (p *parserStruct) extractMethods(typ *ast.InterfaceType) map[string]Method {
	methods := make(map[string]Method)
	for _, m := range typ.Methods.List {
		name := m.Names[0].Name

		fnTyp := m.Type.(*ast.FuncType)
		params := fnTyp.Params.List
		if len(params) != 2 {
			p.Fatalf("Error: Method %v must have exactly 2 arguments\n", name)
		}
		inputName := p.extractTypeName(name, params[1].Type)

		results := fnTyp.Results.List
		if len(results) != 2 {
			p.Fatalf("Error: Method %v must have exactly 2 results\n", name)
		}
		outputName := p.extractTypeName(name, results[0].Type)

		methods[name] = Method{
			Name:       name,
			InputType:  inputName,
			OutputType: outputName,
		}
	}
	return methods
}

func (p *parserStruct) extractTypeName(method string, typ ast.Expr) string {
	s := ""
	if t, ok := typ.(*ast.StarExpr); ok {
		typ = t.X
		s = "*"
	}

	switch typ := typ.(type) {
	case *ast.Ident:
		return s + typ.Name

	case *ast.SelectorExpr:
		x := (typ.X).(*ast.Ident)
		return s + x.Name + "." + typ.Sel.Name

	default:
		err := ast.Print(p.fset, typ)
		if err != nil {
			panic(err)
		}
		p.Fatalf("Unable to parse type")
	}
	return "[ERROR]"
}

func extractImports(ims []*ast.ImportSpec) []Import {
	r := make([]Import, len(ims))
	for i, im := range ims {

		// strip surrounding quotation marks (")
		path := im.Path.Value[1 : len(im.Path.Value)-1]

		name := ""
		full := im.Path.Value
		if im.Name != nil {
			name = im.Name.Name
			full = name + " " + im.Path.Value
		}
		r[i] = Import{
			Full: full,
			Name: name,
			Path: path,
		}
	}
	return r
}

func (p *parserStruct) Fatalf(format string, args ...interface{}) {
	fmt.Printf("Error parsing file: %v (%v)\n", p.inputFilePath, p.serviceNames)
	if format[len(format)-1] != '\n' {
		format += "\n"
	}
	fmt.Printf(format, args)
	os.Exit(1)
}
