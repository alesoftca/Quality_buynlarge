package main

import (
	"log"
	"net/http"

	"github.com/alesoftca/buynlarge/db"
	"github.com/alesoftca/buynlarge/handlers"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	if err := db.InitDB(); err != nil {
		log.Fatalf("Error initializing database: %v", err)
	}

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Get("/ping", handlers.Ping())
	r.Get("/products", handlers.GetProducts(db.DB))
	r.Get("/products/{id}", handlers.GetProduct(db.DB))
	r.Post("/products", handlers.CreateProduct(db.DB))
	r.Put("/products/{id}", handlers.UpdateProduct(db.DB))
	r.Delete("/products/{id}", handlers.DeleteProduct(db.DB))

	r.Put("/products/{id}/stock", handlers.UpdateStock(db.DB))
	r.Post("/sales", handlers.CreateSale(db.DB))

	r.Post("/openai", handlers.OpenAIHandler(db.DB))

	log.Println("Server started on :8080")
	if err := http.ListenAndServe(":8080", r); err != nil {
		log.Fatalf("Error starting server: %v", err)
	}
}
