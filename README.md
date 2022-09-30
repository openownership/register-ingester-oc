# Register Ingester OC

This is an application for ingesting the OpenCorporates bulk data published monthly into an Elasticsearch database.

## One-time Setup

Create a .env file with the keys populated from the .env.example file.

### Create ES indexes

```shell
bin/run es_index_creator
```

## Ingesting Bulk Data

### 1. Download file

You will be prompted for your SFTP password for the OpenCorporates download.

```shell
bin/run download_from_oc companies {REM_FOLDER_NAME} {LOCAL_PATH}
bin/run download_from_oc companies /oc-sftp-prod/open_ownership/2022-09-01 /storage/oc_file_companies
```

### 2. Split and upload file in Gzipped parts to S3

```shell
bin/run upload_split_bulk_data companies {MONTH} {LOCAL_PATH}
bin/run upload_split_bulk_data companies 2022_09 /storage/oc_file_companies
```

### 3. Create Athena tables

Create Athena tables if not already created

```shell
bin/run create_tables companies
```

### 4. Convert OC bulk data using Athena

```shell
bin/run convert_oc_data companies 2022_09
```

### 5. Export OC bulk data for ingest into Elasticsearch

```shell
bin/run export_oc_data companies 2022_09
```

### 6. Ingest S3 exported files into Elasticsearch

To import the full data for a month:
```shell
bin/run ingest_into_es companies 2022_09
```

# Alternate Names

## One-time Setup

```shell
bin/run create_tables add_ids
```

## Monthly Import

```shell
bin/run download_from_oc add_ids /oc-sftp-prod/open_ownership/2022-07-04 /storage/oc_file_add_ids
bin/run upload_split_bulk_data add_ids 2022_09 /storage/oc_file_add_ids
bin/run convert_oc_data add_ids 2022_09
bin/run export_oc_data add_ids 2022_09
bin/run ingest_into_es add_ids 2022_09
```

# Additional Identifiers

## One-time Setup

```shell
bin/run create_tables alt_names
```

## Monthly Import

```shell
bin/run download_from_oc alt_names /oc-sftp-prod/open_ownership/2022-07-04 /storage/oc_file_alt_names
bin/run upload_split_bulk_data alt_names 2022_09 /storage/oc_file_alt_names
bin/run convert_oc_data alt_names 2022_09
bin/run export_oc_data alt_names 2022_09
bin/run ingest_into_es alt_names 2022_09
```
