package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/syndtr/goleveldb/leveldb"
)

func main() {
	// Open LevelDB
	var err error
	var DB_TX *leveldb.DB
	DB_TX, err = leveldb.OpenFile("../db/tx", nil)
	if err != nil {
		log.Fatal(err)
	}
	defer DB_TX.Close()

	// Initialize Fiber app
	app := fiber.New()

	// GET route (e.g., curl http://localhost:8898?key=key1)
	app.Get("/", func(c *fiber.Ctx) error {
		key := c.Query("key")
		if key == "" {
			return c.SendString("Key is required")
		}

		value, err := DB_TX.Get([]byte(key), nil)
		if err != nil {
			return c.SendString("")
		}

		return c.SendString(string(value))
	})

	// POST route (e.g., curl -X POST -H "Content-Type: application/json" -d '{"key":"key1","value":"value1"}' http://localhost:8898)
	app.Post("/", func(c *fiber.Ctx) error {
		var body struct {
			Key   string `json:"key"`
			Value string `json:"value"`
		}

		if err := c.BodyParser(&body); err != nil {
			return c.Status(fiber.StatusBadRequest).SendString("Invalid body")
		}

		err := DB_TX.Put([]byte(body.Key), []byte(body.Value), nil)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).SendString("Failed to store the data")
		}

		return c.SendString("ok")
	})

	// Start server
	log.Fatal(app.Listen(":8898"))
}
