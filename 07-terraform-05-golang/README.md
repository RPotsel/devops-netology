# 7.5. Основы golang - Роман Поцелуев

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

__Ответ:__

```BASH
$ go version
go version go1.13.8 linux/amd64
```

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

__Ответ:__

Пройдены разделы Basics, Methods and interfaces.

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```

__Ответ:__

```GO
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
```

2. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```

__Ответ:__

```GO
package main

import "fmt"

func findMinMaxInArr(a []int) (min int, max int) {
	min = a[0]
	max = a[0]
	for _, value := range a {
		if value < min {
			min = value
		}
		if value > max {
			max = value
		}
	}
	return min, max
}

func main() {
	var x = []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}
	min, max := findMinMaxInArr(x)
	fmt.Printf("Min: %v Max: %v\n", min, max)
}
```

3. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код.

__Ответ:__

```GO
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
```

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания. 

__Ответ:__

Тест для программы, переводящей метры в футы

```GO
package main

import "testing"

func TestMain(t *testing.T) {
	var v float64
	v = meters2feet(5)
	if v != 16.405 {
		t.Errorf("Result was incorrect, got: %v, want: %v.", v, 16.405)
	}
}
```

Тест для программы поиска минимального и максимального числа в списке

```GO
package main

import "testing"

func TestMain(t *testing.T) {
	min, max := findMinMaxInArr([]int{-2, 0, 3, -1, 5, 2, 7, 4})
	if min != -2 && max != 7 {
		t.Errorf("Result was incorrect, got: %v, %v, want: -2, 7.",
			min, max)
	}
}
```