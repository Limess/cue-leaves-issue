package config

import (
	"strings"
)

#PipelineRuleDefinition: #PrometheusRecordingRule & {
	record: =~"pipeline_workload_document_input_rate_.*"
	labels: {
		pipeline: string
	}
}

_pipeline_latency_time_ranges: ["2m", "5m", "30m", "1h", "6h", "1d", "3d", "28d"]
_pipeline_latency_quantiles: ["0.9", "0.99", "0.999"]

// For each pipeline definition, generate Sloth SLO config
pipeline_rules: {
	for k, v in pipeline {
		"\(v.name)": [
			for t in _pipeline_latency_time_ranges {
				#PipelineRuleDefinition & {
					record: "pipeline_workload_document_input_rate_\(t)"
					expr:   "some_rule_for{job=\"\(v.name)\"}"
					labels: {
						pipeline: v.name
					}
				}
			},
		]
	}
}

prometheus_rule_groups: [string]: #PrometheusRules

// ideally this should contain a concatentation of rules for both pipelines "a", and "b"
_monitored_pipelines_label: "(" + strings.Join([ for k, v in pipeline {v.name}], "|") + ")"

// export generic pipeline latency rules to support dashboarding
prometheus_rule_groups: "generic-pipeline": {
	groups: [#PrometheusRuleGroup & {
		name:     "GenericPipelineLatency"
		interval: "1m"
		rules: [
			for t in _pipeline_latency_time_ranges {
				record: "generic_rate\(t)"
				expr:   "sum(rate(generic_rate_metric{pipeline=~\"\(_monitored_pipelines_label)\"}[\(t)])) by (pipeline, job, le)"
			},
		]
	}]
}

prometheus_rule_groups: {for k, v in pipeline_rules {
	"\(k)": {
		groups: [#PrometheusRuleGroup & {
			name:     k
			interval: "1m"
			rules:    v
		}]
	}}}
