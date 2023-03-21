package handler

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	model "github.com/i0n/gokv/pkg/model"
	"github.com/labstack/echo/v4"
	"github.com/stretchr/testify/assert"
)

func TestCreateKey(t *testing.T) {
	keyJSON := `{"id":1,"value":"test-key-1"}`

	e := echo.New()

	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(keyJSON))
	req.Header.Set(echo.HeaderContentType, echo.MIMEApplicationJSON)

	db := map[int]*model.Key{}
	h := &Handler{DB: db}

	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/keys")

	// Assertions
	if assert.NoError(t, h.CreateKey(c)) {
		assert.Equal(t, http.StatusCreated, rec.Code)
		res := strings.TrimSuffix(rec.Body.String(), "\n")
		assert.Equal(t, keyJSON, res)
	}
}

func TestGetAllKeys(t *testing.T) {
	keyJSON := `{"1":{"id":1,"value":"test-key-1"},"2":{"id":2,"value":"test-key-2"}}`

	e := echo.New()

	db := map[int]*model.Key{}
	db[1] = &model.Key{ID: 1, Value: "test-key-1"}
	db[2] = &model.Key{ID: 2, Value: "test-key-2"}
	h := &Handler{DB: db}

	req := httptest.NewRequest(http.MethodGet, "/", nil)
	rec := httptest.NewRecorder()
	c := e.NewContext(req, rec)
	c.SetPath("/keys")

	// Assertions
	if assert.NoError(t, h.GetAllKeys(c)) {
		assert.Equal(t, http.StatusOK, rec.Code)
		res := strings.TrimSuffix(rec.Body.String(), "\n")
		assert.Equal(t, keyJSON, res)
	}
}
