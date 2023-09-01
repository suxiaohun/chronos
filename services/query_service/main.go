package main

import (
	"context"
	"fmt"
	"github.com/ClickHouse/clickhouse-go/v2"
	"github.com/ClickHouse/clickhouse-go/v2/lib/driver"
	"log"
)

func main() {
	conn, err := connect()
	if err != nil {
		panic(err)
	}

	table := "bdp.tracks_all"
	ctx := context.Background()
	rows, err := conn.Query(ctx, "SELECT count(*)  FROM "+table+" LIMIT 1")
	if err != nil {
		log.Fatal(err)
	}

	for rows.Next() {
		var (
			count uint64
		)
		if err := rows.Scan(
			&count,
		); err != nil {
			log.Fatal(err)
		}
		log.Printf("table: %s, total_count: %v",
			table, count)
	}

}

func connect() (driver.Conn, error) {
	var (
		ctx       = context.Background()
		conn, err = clickhouse.Open(&clickhouse.Options{
			Addr: []string{"10.4.243.51:9000"},
			Auth: clickhouse.Auth{
				Database: "bdp",
				Username: "admin",
				Password: "123456",
			},
			ClientInfo: clickhouse.ClientInfo{
				Products: []struct {
					Name    string
					Version string
				}{
					{Name: "an-example-go-client", Version: "0.1"},
				},
			},

			Debugf: func(format string, v ...interface{}) {
				fmt.Printf(format, v)
			},
		})
	)

	if err != nil {
		return nil, err
	}

	if err := conn.Ping(ctx); err != nil {
		if exception, ok := err.(*clickhouse.Exception); ok {
			fmt.Printf("Exception [%d] %s \n%s\n", exception.Code, exception.Message, exception.StackTrace)
		}
		return nil, err
	}
	return conn, nil
}
