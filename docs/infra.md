# 开发基础工具的一些说明

## RustFS

### 用 s3cmd 测试的配置示例

```ini
[default]
access_key = ak-******
secret_key = sk-******
host_base = rustfs:9000
host_bucket = rustfs:9000
use_https = False
signature_v2 = False
bucket_location = us-east-1
region = us-east-1
```
