package main

import (
	"fmt"
	"github.com/drhodes/golorem"
	"math/rand"
	"os"
	"time"
)

const (
	MaxPause = 5
	MaxWords = 30
	MinWords = 5
)

func main() {
	seconds := 0
	message := ""
	s := rand.NewSource(time.Now().UnixNano())
	r := rand.New(s)
	for {
		seconds = r.Intn(MaxPause)
		message = lorem.Sentence(MinWords, MaxWords)
		if seconds%2 == 0 {
			fmt.Printf("[Info] - %s\n", message)
		} else {
			fmt.Fprintf(os.Stderr, "[Error] - %s\n", message)
		}
		time.Sleep(time.Duration(seconds) * time.Second)
	}
}
