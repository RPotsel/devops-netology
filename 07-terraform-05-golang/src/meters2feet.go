package main

import "fmt"

func meters2feet(feet float64) float64 {
	// m = 3.281 ft
	return feet * 3.281
}

func main() {
	var input float64

	fmt.Print("Enter the value in Meters: ")
	fmt.Scanf("%f", &input)
	fmt.Printf("Value in Feet: %v\n", meters2feet(input))
}
