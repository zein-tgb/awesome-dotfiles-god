package ast

import (
	"github.com/arnodel/golua/token"
)

// A Function is an expression node representing a function definition, i.e.
// "function Name(ParList) do Body end".  The Name is optional.
type Function struct {
	Location
	ParList
	Body BlockStat
	Name string
}

var _ ExpNode = Function{}

// NewFunction returns a Function instance built from the given arguments.
func NewFunction(startTok, endTok *token.Token, parList ParList, body BlockStat) Function {
	// Make sure we return at the end of the function
	if body.Return == nil {
		body.Return = []ExpNode{}
	}
	return Function{
		Location: LocFromTokens(startTok, endTok),
		ParList:  parList,
		Body:     body,
	}
}

// ProcessExp uses the given ExpProcessor to process the receiver.
func (f Function) ProcessExp(p ExpProcessor) {
	p.ProcessFunctionExp(f)
}

// HWrite prints a tree representation of the node.
func (f Function) HWrite(w HWriter) {
	w.Writef("(")
	for i, param := range f.Params {
		w.Writef(param.Val)
		if i < len(f.Params)-1 || f.HasDots {
			w.Writef(", ")
		}
	}
	if f.HasDots {
		w.Writef("...")
	}
	w.Writef(")")
	w.Indent()
	w.Next()
	f.Body.HWrite(w)
	w.Dedent()
}

// A ParList represents a function parameter list (it is not a node).
type ParList struct {
	Params  []Name
	HasDots bool
}

// NewParList returns ParList instance for the given parameters.
func NewParList(params []Name, hasDots bool) ParList {
	return ParList{
		Params:  params,
		HasDots: hasDots,
	}
}
