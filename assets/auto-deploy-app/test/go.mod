module gitlab.com/gitlab-org/charts/auto-deploy-app/test

go 1.15

require (
	github.com/cilium/cilium v1.9.16
	github.com/gruntwork-io/terratest v0.32.1
	github.com/stretchr/testify v1.6.1
	k8s.io/api v0.19.16
	k8s.io/apimachinery v0.19.16
)

replace github.com/optiopay/kafka => github.com/cilium/kafka v0.0.0-20180809090225-01ce283b732b
