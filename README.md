# register-ingester-oc
Ingester for Open Corporates Bulk data

## One-time Setup

### Create ES indexes

```shell
bin/run es_index_creator
```

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
bin/run download_from_oc companies {REM_FOLDER_NAME} {LOCAL_PATH}
bin/run download_from_oc companies /oc-sftp-prod/open_ownership/2022-09-01 /storage/oc_file_companies
```

### 4. Split and upload file in Gzipped parts to S3

```shell
bin/run upload_split_bulk_data companies {MONTH} {LOCAL_PATH}
bin/run upload_split_bulk_data companies 2022_09 /storage/oc_file_companies
```

### 5. Create Athena tables

Create Athena tables if not already created

```shell
bin/run create_tables companies
```

### 6. Convert OC bulk data using Athena

```shell
bin/run convert_oc_data companies 2022_09
```

### 7. Export OC bulk data for ingest into Elasticsearch

```shell
bin/run export_oc_data companies 2022_09
```

### 8. Ingest S3 exported files into Elasticsearch

To import the full data for a month:
```shell
bin/run ingest_into_es companies 2022_09
```

# Alternate Names

## One-time Setup

```shell
bundle exec bin/create_tables add_ids
```

## Monthly Import

```shell
bundle exec bin/download_from_oc add_ids /oc-sftp-prod/open_ownership/2022-07-04 /storage/oc_file_add_ids
bundle exec bin/upload_split_bulk_data add_ids 2022_09 /storage/oc_file_add_ids
bundle exec bin/convert_oc_data add_ids 2022_09
bundle exec bin/export_oc_data add_ids 2022_09
bundle exec bin/ingest_into_es add_ids 2022_09
```

# Additional Identifiers

## One-time Setup

```shell
bundle exec bin/create_tables alt_names
```

## Monthly Import

```shell
bundle exec bin/download_from_oc alt_names /oc-sftp-prod/open_ownership/2022-07-04 /storage/oc_file_alt_names
bundle exec bin/upload_split_bulk_data alt_names 2022_09 /storage/oc_file_alt_names
bundle exec bin/convert_oc_data alt_names 2022_09
bundle exec bin/export_oc_data alt_names 2022_09
bundle exec bin/ingest_into_es alt_names 2022_09
```
