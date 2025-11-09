package domain

import "time"

// UserProductView represents a user viewing a product
type UserProductView struct {
	UserID    int       `json:"user_id" bson:"user_id"`
	ProductID int       `json:"product_id" bson:"product_id"`
	ViewedAt  time.Time `json:"viewed_at" bson:"viewed_at"`
}

// UserProductLike represents a user liking a product
type UserProductLike struct {
	UserID    int       `json:"user_id" bson:"user_id"`
	ProductID int       `json:"product_id" bson:"product_id"`
	LikedAt   time.Time `json:"liked_at" bson:"liked_at"`
}

// UserProductPurchase represents a user purchasing a product
type UserProductPurchase struct {
	UserID          int       `json:"user_id" bson:"user_id"`
	ProductID       int       `json:"product_id" bson:"product_id"`
	Quantity        int       `json:"quantity" bson:"quantity"`
	PriceAtPurchase float64   `json:"price_at_purchase" bson:"price_at_purchase"`
	PurchasedAt     time.Time `json:"purchased_at" bson:"purchased_at"`
}

// UserInteractionSummary provides an overview of user's interactions
type UserInteractionSummary struct {
	UserID            int                  `json:"user_id" bson:"user_id"`
	ViewedProducts    []ProductInteraction `json:"viewed_products" bson:"viewed_products"`
	LikedProducts     []ProductInteraction `json:"liked_products" bson:"liked_products"`
	PurchasedProducts []ProductInteraction `json:"purchased_products" bson:"purchased_products"`
	TotalViews        int64                `json:"total_views" bson:"total_views"`
	TotalLikes        int64                `json:"total_likes" bson:"total_likes"`
	TotalPurchases    int64                `json:"total_purchases" bson:"total_purchases"`
}

// ProductInteraction represents a single product interaction with details
type ProductInteraction struct {
	ProductID    int       `json:"product_id" bson:"product_id"`
	ProductName  string    `json:"product_name" bson:"product_name"`
	CategoryID   int       `json:"category_id" bson:"category_id"`
	Price        float64   `json:"price" bson:"price"`
	InteractedAt time.Time `json:"interacted_at" bson:"interacted_at"`
}
