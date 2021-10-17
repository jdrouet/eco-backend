package main

import (
	"database/sql"
	"database/sql/driver"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"reflect"
	"strconv"
	"time"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

var db *sql.DB

func GetDB() *sql.DB {
	var err error

	if db == nil {
		dbHost, dbHostOk := os.LookupEnv("DB_HOST")
		if !dbHostOk {
			dbHost = "localhost"
		}
		dbPort, dbPortOk := os.LookupEnv("DB_PORT")
		if !dbPortOk {
			dbPort = "5432"
		}
		dbName, dbNameOk := os.LookupEnv("DB_NAME")
		if !dbNameOk {
			dbName = "eco"
		}
		dbUser, dbUserOk := os.LookupEnv("DB_USER")
		if !dbUserOk {
			dbUser = "eco"
		}
		dbPassword, dbPasswordOk := os.LookupEnv("DB_PASSWORD")
		if !dbPasswordOk {
			dbPassword = "dummy"
		}
		connStr := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", dbHost, dbPort, dbUser, dbPassword, dbName)
		db, err = sql.Open("postgres", connStr)
		if err != nil {
			panic(err)
		}
	}

	return db
}

func serverAddress() string {
	host, hostOk := os.LookupEnv("HOST")
	if !hostOk {
		host = "localhost"
	}
	port, portOk := os.LookupEnv("PORT")
	if !portOk {
		port = "8080"
	}
	return fmt.Sprintf("%s:%s", host, port)
}

type Payload map[string]interface{}

func (p Payload) Value() (driver.Value, error) {
	return json.Marshal(p)
}

func (p *Payload) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		return errors.New("type assertion to []byte failed")
	}

	return json.Unmarshal(b, &p)
}

// github.com/ugorji/go/codec.MissingFielder.
type LogEntry struct {
	Id        string    `json:"id"`
	CreatedAt time.Time `json:"createdAt"`
	Level     string    `json:"level"`
	Payload   Payload
}

func parseTime(value float64) time.Time {
	return time.Unix(int64(value), 0)
}

func logEntryFromMap(payload map[string]interface{}) (error, LogEntry) {
	var result LogEntry
	result.Payload = make(map[string]interface{})
	for key, element := range payload {
		if key == "id" {
			if reflect.ValueOf(element).Kind() == reflect.String {
				result.Id = element.(string)
			} else {
				return errors.New("invalid type for field id"), result
			}
		} else if key == "createdAt" {
			kind := reflect.ValueOf(element).Kind()
			if kind == reflect.Float64 {
				result.CreatedAt = parseTime(element.(float64))
			} else {
				return errors.New("invalid type for field createdAt"), result
			}
		} else if key == "level" {
			if reflect.ValueOf(element).Kind() == reflect.String {
				result.Level = element.(string)
			} else {
				return errors.New("invalid type for field level"), result
			}
		} else {
			result.Payload[key] = element
		}
	}
	return nil, result
}

func logEntryToMap(item LogEntry) map[string]interface{} {
	result := make(map[string]interface{})
	result["id"] = item.Id
	result["createdAt"] = item.CreatedAt.Unix()
	result["level"] = item.Level
	for key, element := range item.Payload {
		result[key] = element
	}
	return result
}

func decodePayload(payload []map[string]interface{}) (error, []LogEntry) {
	var result []LogEntry
	for _, element := range payload {
		err, item := logEntryFromMap(element)
		if err != nil {
			return err, nil
		} else {
			result = append(result, item)
		}
	}
	return nil, result
}

func status(w http.ResponseWriter, r *http.Request) {
	// nothing to do
}

func publish(w http.ResponseWriter, r *http.Request) {
	reqBody, _ := ioutil.ReadAll(r.Body)
	var payload []map[string]interface{}
	json.Unmarshal(reqBody, &payload)
	decodeErr, elements := decodePayload(payload)
	if decodeErr != nil {
		w.WriteHeader(500)
		log.Fatal(decodeErr)
		return
	}

	stmt := "INSERT INTO mylogs (created_at, level, payload) VALUES ($1, $2, $3)"

	db := GetDB()
	tx, txErr := db.Begin()
	if txErr != nil {
		w.WriteHeader(500)
		log.Fatal(txErr)
		return
	}
	defer tx.Commit()

	for _, element := range elements {
		_, dbErr := db.Exec(stmt, element.CreatedAt, element.Level, element.Payload)
		if dbErr != nil {
			tx.Rollback()
			w.WriteHeader(500)
			log.Fatal(dbErr)
		}
	}
	w.WriteHeader(204)
}

func search(w http.ResponseWriter, r *http.Request) {
	query := r.URL.Query()
	limit := 100
	limitStr, limitPresent := query["limit"]
	if limitPresent && len(limitStr) > 0 {
		limitValue, limitErr := strconv.Atoi(limitStr[0])
		if limitErr != nil {
			w.WriteHeader(500)
			log.Fatal(limitErr)
			return
		}
		if limitValue >= 0 || limitValue <= 200 {
			limit = limitValue
		}
	}
	offset := 0
	offsetStr, offsetPresent := query["offset"]
	if offsetPresent && len(offsetStr) > 0 {
		offsetValue, offsetErr := strconv.Atoi(offsetStr[0])
		if offsetErr != nil {
			w.WriteHeader(500)
			log.Fatal(offsetErr)
			return
		}
		if offsetValue >= 0 {
			offset = offsetValue
		}
	}

	db := GetDB()
	rows, dbErr := db.Query("SELECT id, created_at, level, payload FROM mylogs ORDER BY created_at LIMIT $1 OFFSET $2", limit, offset)
	if dbErr != nil {
		w.WriteHeader(500)
		log.Fatal(dbErr)
		return
	}
	defer rows.Close()
	var result []map[string]interface{}
	for rows.Next() {
		var item LogEntry
		if rowErr := rows.Scan(&item.Id, &item.CreatedAt, &item.Level, &item.Payload); rowErr != nil {
			w.WriteHeader(500)
			log.Fatal(rowErr)
			return
		}
		result = append(result, logEntryToMap(item))
	}
	res, jsonErr := json.Marshal(result)
	if jsonErr != nil {
		w.WriteHeader(500)
		log.Fatal(jsonErr)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(200)
	w.Write(res)
}

func main() {
	address := serverAddress()
	fmt.Printf("Server starting %s\n", address)
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.HandleFunc("/", status)
	myRouter.HandleFunc("/publish", publish).Methods("POST")
	myRouter.HandleFunc("/search", search).Methods("GET")
	log.Fatal(http.ListenAndServe(address, myRouter))
}
