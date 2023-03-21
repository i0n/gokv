package main

import (
	"log"

	handler "github.com/i0n/gokv/pkg/handler"
	model "github.com/i0n/gokv/pkg/model"
	version "github.com/i0n/gokv/pkg/version"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {

	log.Println("#####################################################################")
	log.Println()
	log.Println("Version: " + version.GetVersion())
	log.Println("Revision: " + version.GetRevision())
	log.Println("Branch: " + version.GetBranch())
	log.Println("Built By: " + version.GetBuildUser())
	log.Println("Build Date: " + version.GetBuildDate())
	log.Println("Go Version: " + version.GetGoVersion())
	log.Println()
	log.Println("#####################################################################")

	e := echo.New()

	// Middleware
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	db := map[int]*model.Key{}
	h := &handler.Handler{DB: db}

	// Routes
	e.GET("/keys", h.GetAllKeys)
	e.POST("/keys", h.CreateKey)
	e.GET("/keys/:id", h.GetKey)
	e.PUT("/keys/:id", h.UpdateKey)
	e.DELETE("/keys/:id", h.DeleteKey)

	// Start server
	e.Logger.Fatal(e.Start(":8080"))
}
