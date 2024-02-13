.PHONY: k8s_m_apply k8s_m_destroy k8s_m_plan

TERRAGRUNT_COMMAND := .gitlab/scripts/k8s_managed_cluster.sh

k8s_m_apply:
	/bin/bash $(TERRAGRUNT_COMMAND) apply

k8s_m_destroy:
	/bin/bash $(TERRAGRUNT_COMMAND) destroy

k8s_m_plan:
	/bin/bash $(TERRAGRUNT_COMMAND) plan
