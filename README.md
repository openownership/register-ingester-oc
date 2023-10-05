# Register Ingester OC

Register Ingester OC is a data ingester for the [OpenOwnership](https://www.openownership.org/en/) [Register](https://github.com/openownership/register) project. It processes bulk data published by [OpenCorporates](https://opencorporates.com), and ingests records into [Elasticsearch](https://www.elastic.co/elasticsearch/). It uses raw records only, and doesn't do any conversion into the [Beneficial Ownership Data Standard (BODS)](https://www.openownership.org/en/topics/beneficial-ownership-data-standard/) format.

## Installation

Install and boot [Register](https://github.com/openownership/register).

Configure your environment using the example file:

```sh
cp .env.example .env
```

Create the Elasticsearch indexes:

```sh
docker compose run ingester-oc create-indexes
```

Create the AWS Athena tables:

```sh
docker compose run ingester-oc create-tables add_ids
docker compose run ingester-oc create-tables alt_names
docker compose run ingester-oc create-tables companies
```

## Usage

Find the directory relating to the data to download, e.g. `2023-10-01`. This is then used in subsequent commands.

Decide on which type of bulk data file to be ingested, e.g. `companies`. The options are:

- `add_ids`
- `alt_names`
- `companies`

There are now two options: you can run the commands step-by-step, or alternatively use the helper script.

### Helper script

Import the bulk data for a month:

```sh
docker compose run ingester-oc import-bulk-data-month 2023-10-01 companies
```

### Step-by-step

Download the bulk data file from OpenCorporates via SFTP (enter the password when prompted):

```sh
docker compose run ingester-oc download-from-oc companies /oc-sftp-prod/open_ownership/2023-10-01 storage/oc_file_companies
```

Split and upload file in Gzipped parts to AWS S3:

```sh
docker compose run ingester-oc upload-split-bulk-data companies 2023_10 storage/oc_file_companies
```

Convert OpenCorporates bulk data using AWS Athena:

```sh
docker compose run ingester-oc convert-oc-data companies 2023_10
```

Export OpenCorporates bulk data for ingestion into Elasticsearch:

```sh
docker compose run ingester-oc export-oc-data companies 2023_10
```

Ingest AWS S3 exported files into Elasticsearch:

```sh
docker compose run ingester-oc ingest-into-es companies 2023_10
```
