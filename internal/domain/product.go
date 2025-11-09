package domain

import (
	"time"
)

// Product represents a product in the catalog
type Product struct {
	ID          int       `json:"id" bson:"_id"`
	Name        string    `json:"name" bson:"name"`
	Description string    `json:"description" bson:"description"`
	CategoryID  *int      `json:"category_id,omitempty" bson:"category_id,omitempty"`
	Price       float64   `json:"price" bson:"price"`
	Stock       int       `json:"stock" bson:"stock"`
	ImageURL    string    `json:"image_url,omitempty" bson:"image_url,omitempty"`
	IsActive    bool      `json:"is_active" bson:"is_active"`
	CreatedAt   time.Time `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" bson:"updated_at"`
}

// Category represents a product category
type Category struct {
	ID          int       `json:"id" bson:"_id"`
	Name        string    `json:"name" bson:"name"`
	Description string    `json:"description,omitempty" bson:"description,omitempty"`
	ParentID    *int      `json:"parent_id,omitempty" bson:"parent_id,omitempty"`
	CreatedAt   time.Time `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" bson:"updated_at"`
}

// ProductWithCategory includes category details
type ProductWithCategory struct {
	ID           int       `json:"id" bson:"_id"`
	Name         string    `json:"name" bson:"name"`
	Description  string    `json:"description" bson:"description"`
	CategoryID   *int      `json:"category_id,omitempty" bson:"category_id,omitempty"`
	Price        float64   `json:"price" bson:"price"`
	Stock        int       `json:"stock" bson:"stock"`
	ImageURL     string    `json:"image_url,omitempty" bson:"image_url,omitempty"`
	IsActive     bool      `json:"is_active" bson:"is_active"`
	CreatedAt    time.Time `json:"created_at" bson:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" bson:"updated_at"`
	CategoryName string    `json:"category_name,omitempty" bson:"category_name,omitempty"`
}

// ProductFilter represents filtering options for products
type ProductFilter struct {
	CategoryID  *int
	MinPrice    *float64
	MaxPrice    *float64
	IsActive    *bool
	SearchQuery string
	Limit       int
	Offset      int
	SortBy      string // name, price, created_at
	SortOrder   string // asc, desc
}

// ProductStatistics represents aggregated product metrics
type ProductStatistics struct {
	ProductID     int     `bson:"product_id" json:"product_id"`
	ProductName   string  `bson:"product_name" json:"product_name"`
	ViewCount     int64   `bson:"view_count" json:"view_count"`
	LikeCount     int64   `bson:"like_count" json:"like_count"`
	PurchaseCount int64   `bson:"purchase_count" json:"purchase_count"`
	AverageRating float64 `bson:"average_rating" json:"average_rating"`
	ReviewCount   int64   `bson:"review_count" json:"review_count"`
}
