package service

import (
	"context"

	"github.com/PrimeraAizen/e-comm/internal/repository"
)

type Example interface {
	ExampleMethod() error
}

type Health interface {
	Ping(ctx context.Context) error
}

type ExampleServiceDeps struct {
	repo repository.Example
}

func NewExampleService(repo repository.Example) *ExampleServiceDeps {
	return &ExampleServiceDeps{
		repo: repo,
	}
}

func (e *ExampleServiceDeps) ExampleMethod() error {
	return e.repo.ExampleMethod()
}

type HealthServiceDeps struct {
	repo repository.Health
}

func NewHealthService(repo repository.Health) *HealthServiceDeps {
	return &HealthServiceDeps{repo: repo}
}

func (s *HealthServiceDeps) Ping(ctx context.Context) error {
	return s.repo.Ping(ctx)
}
