// Package render handles the rending of common API results.
package render

import (
	"encoding/json"
	"net/http"

	"github.com/sirupsen/logrus"
)

var (
	jsonContentType        = "application/json"
	jsonContentTypeCharset = "application/json; charset=utf-8"
)

type apiResponseBody struct {
	responseMeta `json:"meta,omitempty"`
	Payload      interface{} `json:"payload,omitempty"`
}

type responseMeta struct {
	Status int   `json:"status,omitempty"`
	Error  error `json:"error,omitempty"`
}

// JSON escribe un payload como json en la respuesta.
func JSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", jsonContentType)
	w.WriteHeader(status)

	body := apiResponseBody{
		responseMeta: responseMeta{
			Status: status},
		Payload: payload}

	writeJSONBody(w, body)
}

// writeJSONBody se encarga de ordenar y escribir el cuerpo de la respuesta.
func writeJSONBody(w http.ResponseWriter, body apiResponseBody) {
	encoded, err := json.MarshalIndent(body, "", "    ")
	if err != nil {
		logrus.Error(err)
	}

	w.Write(encoded)
}
