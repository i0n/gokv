package handler

import (
	"net/http"
	"strconv"
	"sync"

	model "github.com/i0n/gokv/pkg/model"
	"github.com/labstack/echo/v4"
)

type Handler struct {
	DB map[int]*model.Key
}

var (
	seq  = 1
	lock = sync.Mutex{}
)

func (h *Handler) CreateKey(c echo.Context) error {
	lock.Lock()
	defer lock.Unlock()
	k := &model.Key{
		ID: seq,
	}
	if err := c.Bind(k); err != nil {
		return err
	}
	h.DB[k.ID] = k
	seq++
	return c.JSON(http.StatusCreated, k)
}

func (h *Handler) GetKey(c echo.Context) error {
	lock.Lock()
	defer lock.Unlock()
	id, _ := strconv.Atoi(c.Param("id"))
	return c.JSON(http.StatusOK, h.DB[id])
}

func (h *Handler) UpdateKey(c echo.Context) error {
	lock.Lock()
	defer lock.Unlock()
	k := new(model.Key)
	if err := c.Bind(k); err != nil {
		return err
	}
	id, _ := strconv.Atoi(c.Param("id"))
	h.DB[id].Value = k.Value
	return c.JSON(http.StatusOK, h.DB[id])
}

func (h *Handler) DeleteKey(c echo.Context) error {
	lock.Lock()
	defer lock.Unlock()
	id, _ := strconv.Atoi(c.Param("id"))
	delete(h.DB, id)
	return c.NoContent(http.StatusNoContent)
}

func (h *Handler) GetAllKeys(c echo.Context) error {
	lock.Lock()
	defer lock.Unlock()
	return c.JSON(http.StatusOK, h.DB)
}
