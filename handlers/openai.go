package handlers

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/sashabaranov/go-openai"
)

func OpenAIHandler(db *sql.DB) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Prompt string `json:"prompt"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Paso 1: Consultar la base de datos para obtener información relevante de inventario
		var context string
		if contains(req.Prompt, []string{"computadoras", "laptops", "inventario", "stock", "impresoras", "monitores"}) {
			var obj = "'Computadora'"
			if contains(req.Prompt, []string{"impresoras"}) {
				obj = "'Impresora'"
			} else if contains(req.Prompt, []string{"monitores"}) {
				obj = "'Monitor'"
			}
			cmd := "SELECT Marca, Stock FROM Productos WHERE Categoria = " + obj
			time.Sleep(1 * time.Second)
			rows, err := db.Query(cmd)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			defer rows.Close()

			var productos []string
			for rows.Next() {
				var marca string
				var stock int
				if err := rows.Scan(&marca, &stock); err != nil {
					http.Error(w, err.Error(), http.StatusInternalServerError)
					return
				}
				productos = append(productos, fmt.Sprintf("%s (%d disponibles)", marca, stock))
			}

			if len(productos) > 0 {
				context = "Actualmente tenemos el siguiente stock: " + strings.Join(productos, ", ") + "."
			} else {
				context = "No hay stock disponible para esa categoría en este momento."
			}
		} else {
			context = "No tengo información específica sobre ese tema."
		}

		// Paso 2: Usar OpenAI para generar una respuesta basada en el contexto
		client := openai.NewClient(os.Getenv("OPENAI_API_KEY"))
		resp, err := client.CreateChatCompletion(r.Context(), openai.ChatCompletionRequest{
			Model: openai.GPT3Dot5Turbo,
			Messages: []openai.ChatCompletionMessage{
				{
					Role:    openai.ChatMessageRoleSystem,
					Content: "Eres un asistente útil que responde preguntas sobre el inventario de productos. " + context,
				},
				{
					Role:    openai.ChatMessageRoleUser,
					Content: req.Prompt,
				},
			},
		})
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		// Paso 3: Devolver la respuesta generada por OpenAI
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp.Choices[0].Message.Content)
	}
}

// Función auxiliar para verificar si un prompt contiene palabras clave
func contains(prompt string, keywords []string) bool {
	for _, keyword := range keywords {
		if strings.Contains(strings.ToLower(prompt), strings.ToLower(keyword)) {
			return true
		}
	}
	return false
}
