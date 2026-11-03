package test

import (
	"net/http/httptest"
	"testing"

	"github.com/Orodss/baseJudge/internal/infra/server"
)

func TestServer(t *testing.T) {
	serv := server.NewHTTPServer()
	serv.MountRoutes()

	req := httptest.NewRequest("GET", "/health", nil)
	resp, err := serv.GetApp().Test(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		t.Errorf("Expected 200, got %d", resp.StatusCode)
	}
}
