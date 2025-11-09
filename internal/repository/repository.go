package repository

import mongodb "github.com/PrimeraAizen/e-comm/pkg/adapter/mongodb"

type Repository struct {
	Example     Example
	Health      Health
	User        UserRepository
	Profile     ProfileRepository
	Product     ProductRepository
	Interaction InteractionRepository
}

func NewRepositories(db *mongodb.MongoDB) *Repository {
	return &Repository{
		Example:     NewExampleRepository(db),
		Health:      NewHealthRepository(db),
		User:        NewUserRepository(db),
		Profile:     NewProfileRepository(db),
		Product:     NewProductRepository(db),
		Interaction: NewInteractionRepository(db),
	}
}
