package main

import "fmt"

func intDivBy3() (retArr []int) {
	for i := 1; i <= 100; i++ {
		if i%3 == 0 {
			retArr = append(retArr, i)
		}
	}
	return
}

func main() {
	by3 := intDivBy3()
	fmt.Printf("Целочисленное деление на 3 для чисел от 1 до 100: %v\n", by3)
}
