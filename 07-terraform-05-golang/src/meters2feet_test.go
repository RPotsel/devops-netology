package main

import "testing"

func TestMain(t *testing.T) {
	var v float64
	v = meters2feet(5)
	if v != 16.405 {
		t.Errorf("Result was incorrect, got: %v, want: %v.", v, 16.405)
	}
}
