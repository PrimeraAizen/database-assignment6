package domain

import (
	"errors"
)

var (
	ErrValidation         = errors.New("validation failed")
	ErrNotFound           = errors.New("not found")
	ErrAlreadyExists      = errors.New("already exists")
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrInvalidToken       = errors.New("invalid token")
	ErrUserInactive       = errors.New("user inactive")
	ErrUnauthorized       = errors.New("unauthorized")
)
