# Register Ingester OC

This is an application for ingesting the OpenCorporates bulk data published monthly into an Elasticsearch database.

## Installation

Install and boot [register-v2](https://github.com/openownership/register-v2).

Configure your environment using the example file:

```sh
cp .env.example .env
```

Create the Elasticsearch indexes:

```sh
docker compose run ingester-oc create-indexes
```

## Ingesting Bulk Data

Find the directory relating to the data to download, e.g. `2022-09-01`. This is then used in subsequent commands.

You will be prompted for your SFTP password for the OpenCorporates download.

### Companies

#### 1. Download file

```sh
docker compose run ingester-oc download-from-oc companies /oc-sftp-prod/open_ownership/2022-09-01 storage/oc_file_companies
```

#### 2. Split and upload file in Gzipped parts to S3

```sh
docker compose run ingester-oc upload-split-bulk-data companies 2022_09 storage/oc_file_companies
```

#### 3. Create Athena tables

Create Athena tables if not already created

```sh
docker compose run ingester-oc create-tables companies
```

#### 4. Convert OC bulk data using Athena

```sh
docker compose run ingester-oc convert-oc-data companies 2022_09
```

#### 5. Export OC bulk data for ingest into Elasticsearch

```sh
docker compose run ingester-oc export-oc-data companies 2022_09
```

#### 6. Ingest S3 exported files into Elasticsearch

To import the full data for a month:

```sh
docker compose run ingester-oc ingest-into-es companies 2022_09
```

### Additional Identifiers

#### One-time Setup

```shell
docker compose run ingester-oc create-tables add_ids
```

#### Monthly Import

```shell
docker compose run ingester-oc download-from-oc add_ids /oc-sftp-prod/open_ownership/2022-07-04 storage/oc_file_add_ids
docker compose run ingester-oc upload-split-bulk-data add_ids 2022_09 storage/oc_file_add_ids
docker compose run ingester-oc convert-oc-data add_ids 2022_09
docker compose run ingester-oc export-oc-data add_ids 2022_09
docker compose run ingester-oc ingest-into-es add_ids 2022_09
```

### Alternate Names

#### One-time Setup

```shell
docker compose run ingester-oc create-tables alt_names
```

#### Monthly Import

```shell
docker compose run ingester-oc download-from-oc alt_names /oc-sftp-prod/open_ownership/2022-07-04 storage/oc_file_alt_names
docker compose run ingester-oc upload-split-bulk-data alt_names 2022_09 storage/oc_file_alt_names
docker compose run ingester-oc convert-oc-data alt_names 2022_09
docker compose run ingester-oc export-oc-data alt_names 2022_09
docker compose run ingester-oc ingest-into-es alt_names 2022_09
```
