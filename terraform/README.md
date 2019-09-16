## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami |  | map | `<map>` | no |
| availability\_zones |  | list | `<list>` | no |
| aws\_profile |  | string | `"default"` | no |
| aws\_region |  | string | `"us-east-1"` | no |
| common\_tags |  | map | `<map>` | no |
| deployment\_name |  | string | `"rajesh"` | no |
| private\_subnet |  | list | `<list>` | no |
| public\_subnet |  | list | `<list>` | no |
| vpc\_cidr |  | string | `"192.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| current\_ip |  |