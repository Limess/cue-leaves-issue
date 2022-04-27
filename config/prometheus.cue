package config

#Annotations: #Labels & {
	runbook:     string
	description: string
	title:       string
}

#PrometheusMetricName: =~"^[a-zA-Z_:][a-zA-Z0-9_:]*$"

#PrometheusRecordingRule: {
	record:  string
	expr:    string
	labels?: #Labels
}

#PrometheusAlertRule: {
	alert:       string
	expr:        string
	for?:        string
	labels?:     #Labels
	annotations: #Annotations
}

#PrometheusRule: #PrometheusRecordingRule | #PrometheusAlertRule

#PrometheusRuleGroup: {
	name:      string
	interval?: string
	rules: [...#PrometheusRule]
}

#PrometheusRules: {
	groups: [...#PrometheusRuleGroup]
}
