package farm

type CowReport struct {
	CowID      string `json:"cow_id"`
	ReportData string `json:"report_data"`
}

type QueryResult struct {
	Report *CowReport `json:"cow_report"`
	Timestamp string `json:"timestamp"`
}