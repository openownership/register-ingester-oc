# register-ingester-oc
Ingester for Open Corporates Bulk data

## One-time Setup

### Create ES indexes

```shell
bundle exec bin/es_index_creator
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
bundle exec bin/download_from_oc companies {REM_FOLDER_NAME} {LOCAL_PATH}
bundle exec bin/download_from_oc companies /oc-sftp-prod/open_ownership/2022-07-04 /tmp/oc_file_companies
```

### 4. Split and upload file in Gzipped parts to S3

```shell
bundle exec bin/upload_split_bulk_data companies {MONTH} {LOCAL_PATH} 
bundle exec bin/upload_split_bulk_data companies 2022_07 /tmp/oc_file_companies
```

### 5. Create Athena tables

Create Athena tables if not already created

```shell
bundle exec bin/create_tables companies
```

### 6. Convert OC bulk data using Athena

```shell
bundle exec bin/convert_oc_data companies 2022_07
```

### 7. Export OC bulk data for ingest into Elasticsearch

```shell
bundle exec bin/export_oc_data companies 2022_07
```

### 8. Ingest S3 exported files into Elasticsearch

To import the full data for a month:
```shell
bundle exec bin/ingest_into_es companies 2022_07
```

# Alternate Names

## One-time Setup

```shell
bundle exec bin/create_tables add_ids
```

## Monthly Import

```shell
bundle exec bin/download_from_oc add_ids /oc-sftp-prod/open_ownership/2022-07-04 /tmp/oc_file_add_ids
bundle exec bin/upload_split_bulk_data add_ids 2022_07 /tmp/oc_file_add_ids
bundle exec bin/convert_oc_data add_ids 2022_07
bundle exec bin/export_oc_data add_ids 2022_07
bundle exec bin/ingest_into_es add_ids 2022_07
```

# Additional Identifiers

## One-time Setup

```shell
bundle exec bin/create_tables alt_names
```

## Monthly Import

```shell
bundle exec bin/download_from_oc alt_names /oc-sftp-prod/open_ownership/2022-07-04 /tmp/oc_file_alt_names
bundle exec bin/upload_split_bulk_data alt_names 2022_07 /tmp/oc_file_alt_names
bundle exec bin/convert_oc_data alt_names 2022_07
bundle exec bin/export_oc_data alt_names 2022_07
bundle exec bin/ingest_into_es alt_names 2022_07
```
