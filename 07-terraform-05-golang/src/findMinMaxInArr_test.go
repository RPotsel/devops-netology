package main

import "testing"

func TestMain(t *testing.T) {
	min, max := findMinMaxInArr([]int{-2, 0, 3, -1, 5, 2, 7, 4})
	if min != -2 && max != 7 {
		t.Errorf("Result was incorrect, got: %v, %v, want: -2, 7.",
			min, max)
	}
}
