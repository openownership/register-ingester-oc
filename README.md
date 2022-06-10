# register-ingester-oc
Ingester for Open Corporates Bulk data

## Ingesting Bulk Data

### 1. Start the EC2 instance

https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#Instances:v=3
open-corporates-import

### 2. Pull latest code and install dependencies

```shell
cd ?
git pull
bundle install
```

### 3. Download file

You will be prompted for your SFTP password for the OpenCorporates download.

```shell
bundle exec bin/download_from_oc {LOCAL_PATH}
```

### 4. Split and upload file in Gzipped parts to S3

```shell
bundle exec bin/upload_split_bulk_data {LOCAL_PATH}
```

WIP:
- ENV vars
- Modify month 2022_05 to 202205

### 5. Create Athena tables

Create Athena tables if not already created

```shell
bundle exec bin/create_tables
```

### 6. Convert OC bulk data using Athena

```shell
bundle exec bin/convert_oc_data 202205
```

### 7. Export OC bulk data for ingest into Elasticsearch

```shell
bundle exec bin/export_oc_data 202205
```
