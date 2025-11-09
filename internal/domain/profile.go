package domain

import (
	"time"
)

// Profile represents detailed user profile information
type Profile struct {
	ID          int        `json:"id" bson:"_id"`
	UserID      int        `json:"user_id" bson:"user_id"`
	FirstName   string     `json:"first_name" bson:"first_name"`
	LastName    string     `json:"last_name" bson:"last_name"`
	MiddleName  *string    `json:"middle_name,omitempty" bson:"middle_name,omitempty"`
	DateOfBirth *time.Time `json:"date_of_birth,omitempty" bson:"date_of_birth,omitempty"`
	Gender      *string    `json:"gender,omitempty" bson:"gender,omitempty"`
	Phone       *string    `json:"phone,omitempty" bson:"phone,omitempty"`
	Address     *string    `json:"address,omitempty" bson:"address,omitempty"`
	City        *string    `json:"city,omitempty" bson:"city,omitempty"`
	Country     *string    `json:"country,omitempty" bson:"country,omitempty"`
	PostalCode  *string    `json:"postal_code,omitempty" bson:"postal_code,omitempty"`
	CreatedAt   time.Time  `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at" bson:"updated_at"`
}
