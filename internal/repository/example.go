package repository

import (
	"context"

	mongodb "github.com/PrimeraAizen/e-comm/pkg/adapter/mongodb"
)

type Example interface {
	ExampleMethod() error
}

type Health interface {
	Ping(ctx context.Context) error
}

type ExampleRepository struct {
	db *mongodb.MongoDB
}

func NewExampleRepository(db *mongodb.MongoDB) *ExampleRepository {
	return &ExampleRepository{
		db: db,
	}
}

func (e *ExampleRepository) ExampleMethod() error {
	return nil
}

type HealthRepository struct {
	db *mongodb.MongoDB
}

func NewHealthRepository(db *mongodb.MongoDB) *HealthRepository {
	return &HealthRepository{db: db}
}

func (r *HealthRepository) Ping(ctx context.Context) error {
	// Ping MongoDB
	return r.db.Client.Ping(ctx, nil)
}
