package main

import "github.com/Orodss/baseJudge/internal/infra/server"

func main() {
	http_server := server.NewHTTPServer()
	http_server.MountRoutes()
	http_server.Start(":8080")
}