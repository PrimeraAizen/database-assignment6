package main

import (
	"fmt"

	"golang.org/x/crypto/bcrypt"
)

func main() {
	password := "password123"
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		panic(err)
	}
	fmt.Println("Password:", password)
	fmt.Println("Hash:", string(hash))

	// Verify it works
	err = bcrypt.CompareHashAndPassword(hash, []byte(password))
	if err == nil {
		fmt.Println("✓ Hash verification successful")
	} else {
		fmt.Println("✗ Hash verification failed")
	}
}
