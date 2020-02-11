package farm

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/golang/protobuf/ptypes/timestamp"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// alias name for TransactionContextInterface
type Context contractapi.TransactionContextInterface

type FarmContract struct {
	contractapi.Contract
}

type cowReport struct {
	cowID      string `json:"cow_id"`
	reportData string `json:"report_data"`
}

type queryResult struct {
	report    *cowReport `json:"cow_report"`
	timestamp string     `json:"timestamp"`
}

func (c *FarmContract) Instantiate() {
	fmt.Println("Instantiated")
}

func (c *FarmContract) PutCowReport(ctx Context, cowID, reportData string) error {
	report := cowReport{cowID, reportData}
	jsonStr, err := json.Marshal(report)
	if err != nil {
		return fmt.Errorf("json marshal failed, err: %+v", err)
	}
	return ctx.GetStub().PutState(cowID, jsonStr)
}

func (c *FarmContract) GetCowHistory(ctx Context, cowID string) ([]byte, error) {
	histories, err := ctx.GetStub().GetHistoryForKey(cowID)
	if err != nil {
		return nil, fmt.Errorf("GetHistoryForKey failed, cowID: %s, err: %+v", cowID, err)
	}

	var results []queryResult
	for histories.HasNext() {
		history, err := histories.Next()
		if err != nil {
			return nil, fmt.Errorf("GetHistoryForKey failed, cowID:%s err:%+v", cowID, err)
		}
		value := history.GetValue()

		var report cowReport
		if err := json.Unmarshal(value, report); err != nil {
			return nil, fmt.Errorf("unmarshal failed, err: %+v", err)
		}
		ts := history.GetTimestamp()
		results = append(results, queryResult{report: &report, timestamp: timestampToStr(ts)})
	}

	jsonStr, err := json.Marshal(results)
	if err != nil {
		return nil, fmt.Errorf("json marshal failed, err: %+v", err)
	}

	return []byte(jsonStr), nil
}

func timestampToStr(ts *timestamp.Timestamp) string {
	tm := time.Unix(ts.Seconds, 0)
	return tm.Format("2006-01-02 03:04:05 PM")
}
