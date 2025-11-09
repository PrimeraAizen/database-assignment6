package config

import (
	"errors"
	"fmt"
	"strings"

	"github.com/spf13/viper"

	"github.com/PrimeraAizen/e-comm/pkg/logger"
)

// ErrInvalidConfig ошибка конфигурации приложения.
var ErrInvalidConfig = errors.New("invalid config")

// Путь к файлам ключей и директории миграций.
const (
	MigrationDir = "migrations"
	PathToConfig = "./config"
)

type Config struct {
	Http   Http          `mapstructure:"http"`
	Mongo  MongoDB       `mapstructure:"mongodb"`
	Logger logger.Config `mapstructure:"logger"`
	JWT    JWT           `mapstructure:"jwt"`
}

func LoadConfig() (*Config, error) {
	return LoadConfigFromDirectory(PathToConfig)
}

func LoadConfigFromDirectory(path string) (*Config, error) {

	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(path)
	viper.SetEnvPrefix("APP")
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()

	err := viper.ReadInConfig()
	if err != nil {
		return nil, fmt.Errorf("read config: %w", err)
	}

	var cfg Config
	err = viper.Unmarshal(&cfg)
	if err != nil {
		return nil, fmt.Errorf("decode into struct: %w", err)
	}

	err = cfg.Validate()
	if err != nil {
		return nil, err
	}
	return &cfg, nil
}

func (cfg *Config) Validate() error {
	if cfg.Http.Host == "" {
		return fmt.Errorf("missing http host")
	}
	if cfg.Http.Port == "" {
		return fmt.Errorf("missing http port")
	}
	if cfg.Mongo.URI == "" && (cfg.Mongo.Host == "" || cfg.Mongo.Port == "" || cfg.Mongo.Database == "") {
		return fmt.Errorf("missing mongodb connection settings")
	}

	// Build URI if not provided
	if cfg.Mongo.URI == "" {
		if cfg.Mongo.Username != "" && cfg.Mongo.Password != "" {
			cfg.Mongo.URI = fmt.Sprintf("mongodb://%s:%s@%s:%s",
				cfg.Mongo.Username, cfg.Mongo.Password, cfg.Mongo.Host, cfg.Mongo.Port)
		} else {
			cfg.Mongo.URI = fmt.Sprintf("mongodb://%s:%s", cfg.Mongo.Host, cfg.Mongo.Port)
		}
	}

	// Set default pool sizes if not provided
	if cfg.Mongo.MaxPoolSize == 0 {
		cfg.Mongo.MaxPoolSize = 100
	}
	if cfg.Mongo.MinPoolSize == 0 {
		cfg.Mongo.MinPoolSize = 10
	}
	if cfg.Mongo.MaxConnIdleTime == 0 {
		cfg.Mongo.MaxConnIdleTime = 60
	}

	// Set default logger config if not provided
	if cfg.Logger.Level == "" {
		cfg.Logger.Level = logger.LevelInfo
	}
	if cfg.Logger.Format == "" {
		cfg.Logger.Format = "json"
	}
	if cfg.Logger.Output == "" {
		cfg.Logger.Output = "stdout"
	}
	if cfg.Logger.Service == "" {
		cfg.Logger.Service = "template"
	}
	if cfg.Logger.Version == "" {
		cfg.Logger.Version = "1.0.0"
	}
	if cfg.Logger.Environment == "" {
		cfg.Logger.Environment = "development"
	}

	// JWT config validation
	if cfg.JWT.Secret == "" {
		return fmt.Errorf("missing jwt secret")
	}
	if cfg.JWT.AccessTokenDuration == "" {
		cfg.JWT.AccessTokenDuration = "15m"
	}
	if cfg.JWT.RefreshTokenDuration == "" {
		cfg.JWT.RefreshTokenDuration = "168h"
	}

	return nil
}

type Http struct {
	Host string `mapstructure:"host"`
	Port string `mapstructure:"port"`
}

type MongoDB struct {
	URI             string `mapstructure:"uri"`
	Host            string `mapstructure:"host"`
	Port            string `mapstructure:"port"`
	Database        string `mapstructure:"database"`
	Username        string `mapstructure:"username"`
	Password        string `mapstructure:"password"`
	MaxPoolSize     int    `mapstructure:"max_pool_size"`
	MinPoolSize     int    `mapstructure:"min_pool_size"`
	MaxConnIdleTime int    `mapstructure:"max_conn_idle_time"` // in seconds
}

type JWT struct {
	Secret               string `mapstructure:"secret"`
	AccessTokenDuration  string `mapstructure:"access_token_duration"`
	RefreshTokenDuration string `mapstructure:"refresh_token_duration"`
}
