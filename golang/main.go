package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
)

func serverAddress() string {
	address, addressOk := os.LookupEnv("ADDRESS")
	if addressOk {
		return address
	}
	return "localhost:3000"
}

func blackholeUrl() string {
	url, urlOk := os.LookupEnv("BLACKHOLE_URL")
	if urlOk {
		return url
	}
	return "http://localhost:3010"
}

var blackhole string = blackholeUrl()

// UnixTime is our magic type
type UnixTime struct {
	time.Time
}

// UnmarshalJSON is the method that satisfies the Unmarshaller interface
func (u *UnixTime) UnmarshalJSON(b []byte) error {
	var timestamp int64
	err := json.Unmarshal(b, &timestamp)
	if err != nil {
		return err
	}
	u.Time = time.Unix(timestamp, 0)
	return nil
}

// MarshalJSON turns our time.Time back into an int
func (u UnixTime) MarshalJSON() ([]byte, error) {
	return []byte(fmt.Sprintf("%d", (u.Time.Unix()))), nil
}

type Event struct {
	Ts     UnixTime               `json:"ts"`
	Tags   map[string]string      `json:"tags"`
	Values map[string]interface{} `json:"values"`
}

func status(w http.ResponseWriter, r *http.Request) {
	// nothing to do
	w.WriteHeader(204)
}

func publish(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)
	var payload Event
	unmarshalErr := json.Unmarshal(reqBody, &payload)
	if unmarshalErr != nil {
		w.WriteHeader(500)
		log.Fatal(unmarshalErr)
		return
	}
	payload.Tags["through"] = "golang"
	resBody, marshalErr := json.Marshal(payload)
	if marshalErr != nil {
		w.WriteHeader(500)
		log.Fatal(marshalErr)
		return
	}

	resp, err := http.Post(blackhole, "application/json", bytes.NewBuffer(resBody))

	if err != nil {
		w.WriteHeader(500)
		log.Fatal(marshalErr)
		return
	}

	if resp.StatusCode >= 399 {
		w.WriteHeader(resp.StatusCode)
	} else {
		w.WriteHeader(204)
	}
}

func main() {
	address := serverAddress()
	fmt.Printf("Server starting %s\n", address)
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.HandleFunc("/", status)
	myRouter.HandleFunc("/publish", publish).Methods("POST")
	log.Fatal(http.ListenAndServe(address, myRouter))
}
