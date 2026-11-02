package server

import (
	"log"

	"github.com/gofiber/fiber/v3"
)

type HTTPServer interface {
	Start(port string)
	MountRoutes()
	GetApp() *fiber.App
}

type httpServer struct{
	app *fiber.App
}

func NewHTTPServer() HTTPServer{
	app := fiber.New(fiber.Config{
		CaseSensitive : true,
		AppName : "BaseJudge API v1.0.0",
		ServerHeader : "Fiber",
	})
	return &httpServer{
		app : app,
	}
}

func (s *httpServer) GetApp() *fiber.App{
	return s.app
}

func (s *httpServer) MountRoutes(){
	s.app.Get("/", func (c fiber.Ctx) error{
		return c.SendString("Hello From the server")
	})
	v1 := s.app.Group("/v1")
	api := v1.Group("/api")

	api.Get("/",func (c fiber.Ctx) error{
		return c.SendString("HELLO FROM API")
	})
}

func (s *httpServer) Start(port string){
	err := s.app.Listen(port)

	if err != nil{
		log.Fatal(err)
	}
}
