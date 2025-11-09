package mongodb

import (
	"context"
	"fmt"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"

	"github.com/PrimeraAizen/e-comm/config"
)

type MongoDB struct {
	Client   *mongo.Client
	Database *mongo.Database
}

func New(ctx context.Context, cfg *config.MongoDB) (*MongoDB, error) {
	clientOptions := options.Client().
		ApplyURI(cfg.URI).
		SetMaxPoolSize(uint64(cfg.MaxPoolSize)).
		SetMinPoolSize(uint64(cfg.MinPoolSize)).
		SetMaxConnIdleTime(time.Duration(cfg.MaxConnIdleTime) * time.Second)

	// Connect to MongoDB
	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to MongoDB: %w", err)
	}

	// Ping the database
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		return nil, fmt.Errorf("failed to ping MongoDB: %w", err)
	}

	db := client.Database(cfg.Database)

	// Create indexes
	if err := createIndexes(ctx, db); err != nil {
		return nil, fmt.Errorf("failed to create indexes: %w", err)
	}

	return &MongoDB{
		Client:   client,
		Database: db,
	}, nil
}

func (m *MongoDB) Close(ctx context.Context) error {
	if m.Client != nil {
		return m.Client.Disconnect(ctx)
	}
	return nil
}

// Collection returns a collection by name
func (m *MongoDB) Collection(name string) *mongo.Collection {
	return m.Database.Collection(name)
}

// createIndexes creates all necessary indexes for the database
func createIndexes(ctx context.Context, db *mongo.Database) error {
	// Users collection indexes
	usersCollection := db.Collection("users")
	_, err := usersCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys:    bson.D{{Key: "email", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{{Key: "created_at", Value: -1}},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create users indexes: %w", err)
	}

	// Products collection indexes
	productsCollection := db.Collection("products")
	_, err = productsCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{{Key: "name", Value: "text"}, {Key: "description", Value: "text"}},
		},
		{
			Keys: bson.D{{Key: "category_id", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "price", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "created_at", Value: -1}},
		},
		{
			Keys: bson.D{{Key: "is_active", Value: 1}},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create products indexes: %w", err)
	}

	// Categories collection indexes
	categoriesCollection := db.Collection("categories")
	_, err = categoriesCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys:    bson.D{{Key: "name", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{{Key: "parent_id", Value: 1}},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create categories indexes: %w", err)
	}

	// Roles collection index
	rolesCollection := db.Collection("roles")
	_, err = rolesCollection.Indexes().CreateOne(ctx, mongo.IndexModel{
		Keys:    bson.D{{Key: "name", Value: 1}},
		Options: options.Index().SetUnique(true),
	})
	if err != nil {
		return fmt.Errorf("failed to create roles indexes: %w", err)
	}

	// User roles collection indexes
	userRolesCollection := db.Collection("user_roles")
	_, err = userRolesCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys:    bson.D{{Key: "user_id", Value: 1}, {Key: "role_id", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create user_roles indexes: %w", err)
	}

	// Orders collection indexes
	ordersCollection := db.Collection("orders")
	_, err = ordersCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{{Key: "user_id", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "status", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "created_at", Value: -1}},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create orders indexes: %w", err)
	}

	// User product views indexes
	viewsCollection := db.Collection("user_product_views")
	_, err = viewsCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys: bson.D{{Key: "user_id", Value: 1}, {Key: "product_id", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "product_id", Value: 1}},
		},
		{
			Keys: bson.D{{Key: "viewed_at", Value: -1}},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create user_product_views indexes: %w", err)
	}

	// User product likes indexes
	likesCollection := db.Collection("user_product_likes")
	_, err = likesCollection.Indexes().CreateMany(ctx, []mongo.IndexModel{
		{
			Keys:    bson.D{{Key: "user_id", Value: 1}, {Key: "product_id", Value: 1}},
			Options: options.Index().SetUnique(true),
		},
		{
			Keys: bson.D{{Key: "product_id", Value: 1}},
		},
	})
	if err != nil {
		return fmt.Errorf("failed to create user_product_likes indexes: %w", err)
	}

	return nil
}
