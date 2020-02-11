package factory

type QueryResult struct {
	Report *MilkReport `json:"milk_report"`
	Timestamp string `json:"timestamp"`
}

type MilkReport struct {
	MilkID    string `json:"milk_id"`
	CowID     string `json:"cow_id"`
	MachineID string `json:"machine_id"`
	ReportData string `json:"report_data"`
}