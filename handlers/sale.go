package handlers

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
)

func UpdateStock(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		idStr := chi.URLParam(r, "id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			http.Error(w, "Invalid product ID", http.StatusBadRequest)
			return
		}

		var stock struct {
			Stock int `json:"stock"`
		}
		if err := json.NewDecoder(r.Body).Decode(&stock); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		_, err = db.Exec("UPDATE Productos SET Stock = @p1 WHERE ID = @p2", stock.Stock, id)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
	}
}

func CreateSale(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var sale struct {
			ProductoID int `json:"ProductoID"`
			Cantidad   int `json:"Cantidad"`
		}
		if err := json.NewDecoder(r.Body).Decode(&sale); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		_, err := db.Exec("INSERT INTO Ventas (ProductoID, Cantidad, FechaVenta) VALUES (@p1, @p2, GETDATE())", sale.ProductoID, sale.Cantidad)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		_, err = db.Exec("UPDATE Productos SET stock = stock - 1 WHERE stock > 0 AND ID = @p1", sale.ProductoID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
	}
}
