package models

type Product struct {
	ID          int     `json:"ID"`
	Nombre      string  `json:"Nombre"`
	Marca       string  `json:"Marca"`
	Descripcion string  `json:"Descripcion"`
	Precio      float64 `json:"Precio"`
	Stock       int     `json:"Stock"`
	Categoria   string  `json:"Categoria"`
}
