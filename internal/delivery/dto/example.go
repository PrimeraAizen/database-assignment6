package dto

import "github.com/PrimeraAizen/e-comm/internal/domain"

type CreateExample struct {
	ExampleField string `json:"example_field"`
}

func (c *CreateExample) ToDomain() *domain.Example {
	return &domain.Example{
		ExampleField: c.ExampleField,
	}
}
