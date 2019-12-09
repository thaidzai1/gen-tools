package idgen

import (
	"crypto/rand"
	"errors"
	"fmt"
	"io"

	"github.com/oklog/ulid"

	"gicprime.com/sqitch/common/l"
)

var (
	ll = l.New()

	entropy = rand.Reader

	// ErrInvalidLength ...
	ErrInvalidLength = errors.New("Invalid id length")
)

// Alphabet ...
const Alphabet = ulid.Encoding

// Generate ...
func Generate(infix uint16) ulid.ULID {
	return NewWithEntropy(infix, ulid.Now(), entropy)
}

const (
	low6  = byte(1<<6 - 1)
	high2 = ^low6
)

// NewWithEntropy ...
func NewWithEntropy(infix uint16, ms uint64, entropy io.Reader) ulid.ULID {
	id, err := ulid.New(ms, entropy)
	if err != nil {
		ll.Panic("Unable to generate ID", l.Error(err))
		return id
	}
	id[6] = byte(infix)
	id[7] = byte(infix>>8) | (id[7] & low6)
	return id
}

// Parse ...
func Parse(s string) (ulid.ULID, error) {
	return ulid.Parse(s)
}

// GetInfix returns infix from given id
func GetInfix(id ulid.ULID) uint16 {
	return uint16(id[6]) | uint16(id[7]&high2)<<8
}

// CalcInfix returns encoding bytes for infix constants in little endian,
// and encoded as ulid base32 (5 bits per character)
//
//    AB
// -> 10 11 (decimal)
// -> 01010 01011 00000 0
// -> 01010010 11000000
// -> 82 192
// -> 49234
func CalcInfix(s string) uint16 {
	if len(s) != 2 {
		panic(fmt.Sprintf("Invalid infix `%v`", s))
	}

	i0 := charIndex(s[0])
	i1 := charIndex(s[1])
	b0 := i0<<3 | i1>>2
	b1 := (i1 & (1<<2 - 1)) << 6
	return uint16(b1)<<8 | uint16(b0)
}

func charIndex(c byte) byte {
	for i, a := range Alphabet {
		if a == rune(c) {
			return byte(i)
		}
	}

	panic(fmt.Sprintf("Invalid character `%v`", string(c)))
}
