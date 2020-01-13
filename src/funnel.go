package main

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path"
	"sync"
)

type packet struct {
	Chan string `json:"chan"`
	Data []byte `json:"data"`
}

var queue []string
var lock sync.Mutex
var root string

func output() {
	xchPath := path.Join(root, ".xch")
	lockPath := path.Join(root, ".xch.lock")
	for {
		if len(queue) == 0 {
			continue
		}
		fi, err := os.Stat(xchPath)
		if err == nil && fi.Size() > 0 {
			continue
		}
		if _, err = os.Stat(lockPath); err == nil {
			continue
		}
		lock.Lock()
		var pkt string
		pkt, queue = queue[0], queue[1:]
		written := false
		for written == false {
			fd, err := os.OpenFile(lockPath, os.O_RDONLY|os.O_CREATE, 0644)
			if err != nil {
				continue
			}
			fd.Close()
			err = ioutil.WriteFile(xchPath, []byte(pkt), 0644)
			if err == nil {
				written = true
				log.Printf("passed packet %s\n", pkt)
			}
			os.Remove(lockPath)
		}
		lock.Unlock()
	}
}

func main() {
	root = os.Getenv("CS2DFUNNEL_ROOT")
	if len(root) == 0 {
		root = "/out"
	}
	_ = os.Mkdir(root, 0666)

	http.HandleFunc("/recv", func(writer http.ResponseWriter, req *http.Request) {
		lock.Lock()
		defer lock.Unlock()
		recvPacket := &packet{
			Chan: req.URL.Query().Get("chan"),
			Data: []byte(req.URL.Query().Get("data")),
		}
		jsonPkt, _ := json.Marshal(recvPacket)
		log.Printf("queued packet %s\n", jsonPkt)
		queue = append(queue, string(jsonPkt))
	})
	go output()
	log.Print("Funnel listening on port 8090")
	log.Fatal(http.ListenAndServe(":8090", nil))
}
