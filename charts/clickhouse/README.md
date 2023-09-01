# clickhouse

![Version: 5.1.0](https://img.shields.io/badge/Version-5.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 20.3.19-v1.1.0](https://img.shields.io/badge/AppVersion-20.3.19--v1.1.0-informational?style=flat-square)

A Helm chart for Clickhouse

## Values

| Key | Type | Default                                                                                                                         | Description |
|-----|------|---------------------------------------------------------------------------------------------------------------------------------|-------------|
| affinity | object | `{}`                                                                                                                            | pod/node affinity/anti-affinity |
| dep.kafka.auth | object | `{"enabled":true,"passwordRef":"kafka_admin_password","secretName":"kafka-default-secret","usernameRef":"kafka_admin_username"}` | kafka auth |
| dep.kafka.nameSuffix | string | `"default"`                                                                                                                     | kafka name suffix |
| dep.kafka.namespace | string | `"component"`                                                                                                                   | kafka namespace |
| dep.kafka.replicas | int | `3`                                                                                                                             | kafka replicas |
| dep.redis.auth | object | `{"enabled":true,"passwordRef":"redis_admin_password","secretName":"redis-default-secret","usernameRef":"redis_admin_username"}` | redis auth |
| dep.redis.enabled | bool | `true`                                                                                                                          | redis enabled |
| dep.redis.nameSuffix | string | `"olap"`                                                                                                                        | redis name suffix |
| dep.redis.namespace | string | `"component"`                                                                                                                   | redis namespace |
| dep.zk.nameSuffix | string | `"default"`                                                                                                                     | zookeeper name suffix |
| dep.zk.namespace | string | `"component"`                                                                                                                   | zookeeper namespace |
| dep.zk.replicas | int | `3`                                                                                                                             | zookeeper replicas |
| global.dockerRegistry | string | `"10.4.243.51:5000"`                                                                                                            | docker registry address |
| global.hostArch | string | `"amd64"`                                                                                                                       | machine architecture |
| global.isViper | bool | `false`                                                                                                                         | If true, install with viper unique configuration |
| global.monitorNamespace | string | `"monitoring"`                                                                                                                  | prometheus deploy namespace |
| image.pullPolicy | string | `"IfNotPresent"`                                                                                                                | image pull policy |
| image.pullSecrets | list | `["inner"]`                                                                                                                     | image pull secrets |
| image.repository.amd64.busybox | string | `"viper-ce/library/busybox"`                                                                                                    | busybox amd64 image tag |
| image.repository.amd64.clickhouse | string | `"infra/clickhouse/clickhouse-server"`                                                                                          | clickhouse amd64 image repo |
| image.repository.amd64.exporter | string | `"infra/f1yegor/clickhouse-exporter"`                                                                                           | exporter amd64 image repo |
| image.repository.arm64.busybox | string | `"viper-ce/library/busybox"`                                                                                                    | busybox arm64 image tag |
| image.repository.arm64.clickhouse | string | `"infra/clickhouse/clickhouse-server"`                                                                                          | clickhouse arm64 image repo |
| image.repository.arm64.exporter | string | `"infra/f1yegor/clickhouse-exporter"`                                                                                           | exporter arm64 image repo |
| image.tag.amd64.busybox | string | `"1.33.0-amd64"`                                                                                                                | busybox amd64 image tag |
| image.tag.amd64.clickhouse | string | `"v22.1.3.7-stable-e3c1299"`                                                                                                    | clickhouse amd64 image tag |
| image.tag.amd64.exporter | string | `"v1.1.1"`                                                                                                                      | exporter amd64 image tag |
| image.tag.arm64.busybox | string | `"1.33.0-arm64"`                                                                                                                | busybox arm64 image tag |
| image.tag.arm64.clickhouse | string | `"v22.1.3.7-stable-e3c1299-arm64"`                                                                                              | clickhouse arm64 image tag |
| image.tag.arm64.exporter | string | `"v1.1.1-arm64"`                                                                                                                | exporter arm64 image tag |
| init.databases | list | `[{"name":"dbp"}]`                                                                                                              | init databases |
| nameSuffix | string | `"default"`                                                                                                                     | name suffix |
| nodeSelector | object | `{}`                                                                                                                            | node selector |
| persistence.storageClass | string | `"local-clickhouse"`                                                                                                | storageclass name |
| persistence.volumeSize | string | `"10G"`                                                                                                                         | volume size requested |
| podAnnotations | object | `{"pod.alpha.kubernetes.io/initialized":"true"}`                                                                                | pod annotations |
| podSecurityContext | object | `{}`                                                                                                                            | pod security context |
| property.kubePodsSubnet | string | `""`                                                                                                                            | kubernetes pods subnet |
| property.maxMemoryUsage | string | `"90000000000"`                                                                                                                 | max_memory_usage (Bytes), default 90GB |
| property.restPortExternalOpen | bool | `false`                                                                                                                         | open external rest port |
| replicaCount | int | `1`                                                                                                                             | clickhouse replicas |
| resources.amd64 | object | `{"limits":{"cpu":"16","memory":"90Gi"},"requests":{"cpu":"1","memory":"20Gi"}}`                                                | amd64 resources |
| resources.arm64 | object | `{"limits":{"cpu":"1.5","memory":"30Gi"},"requests":{"cpu":"1.5","memory":"30Gi"}}`                                             | arm64 resources |
| securityContext | object | `{}`                                                                                                                            | container security context |
| service.enableServiceMonitor | bool | `true`                                                                                                                          | enable servicemonitor or not |
| service.port.internal | int | `9009`                                                                                                                          | internal server port |
| service.port.metrics | int | `9116`                                                                                                                          | metrics port |
| service.port.rest | int | `8123`                                                                                                                          | rest port |
| service.port.restExternal | int | `31181`                                                                                                                         | rest external node port |
| service.port.rpc | int | `9000`                                                                                                                          | rpc port |
| service.type | string | `"Headless"`                                                                                                                    | service type |
| tolerations | list | `[]`                                                                                                                            | tolerations |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
