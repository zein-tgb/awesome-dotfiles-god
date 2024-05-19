package ast

import (
	"github.com/arnodel/golua/token"
)

// GotoStat is a statement node representing a goto statement.
type GotoStat struct {
	Location
	Label Name
}

var _ Stat = GotoStat{}

// NewGotoStat returns a GotoStat instance with the given label.
func NewGotoStat(gotoTok *token.Token, lbl Name) GotoStat {
	return GotoStat{
		Location: MergeLocations(LocFromToken(gotoTok), lbl),
		Label:    lbl,
	}
}

// ProcessStat uses the given StatProcessor to process the receiver.
func (s GotoStat) ProcessStat(p StatProcessor) {
	p.ProcessGotoStat(s)
}

// HWrite prints a tree representation of the node.
func (s GotoStat) HWrite(w HWriter) {
	w.Writef("goto %s", s.Label)
}
