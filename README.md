# NL Labour Market Explorer

An open-source data product that takes you from raw Dutch labour market data to a finished report, in one command.

Clone the repo, run `./start.sh`, and a report on job vacancies, unemployment and wages across Dutch provinces and sectors opens in your browser. Everything runs in Docker, uses free and open-source tools, and needs no accounts or API keys.

## Business question

How do job vacancies, unemployment and wages differ across Dutch regions and sectors over time, and where is the labour market tight (more vacancies than job seekers) versus slack?

## Key metric

**Labour market tightness** = job vacancies ÷ unemployed persons. A value above 1.0 means more vacancies than job seekers.

## Architecture

```
CBS Open Data (OData API)
        │
        ▼
┌──────────────────────────────┐
│ Airflow (LocalExecutor)      │  schedules and orchestrates
│  1. extract → raw Parquet    │
│  2. load → Postgres raw      │
│  3. dbt build + dbt test     │
└──────────────┬───────────────┘
               ▼
┌──────────────────────────────┐
│ PostgreSQL                   │
│  airflow DB   (metadata)     │
│  warehouse DB                │
│   raw → staging →            │
│   intermediate → marts       │
└──────────────┬───────────────┘
               │ read-only role
               ▼
┌──────────────────────────────┐
│ Evidence (reports as code)   │  renders the report
└──────────────────────────────┘
```

## Technology stack

| Layer | Tool | Licence | Purpose |
|---|---|---|---|
| Data source | CBS Open Data (OData) | CBS open data terms | Dutch labour market statistics |
| Orchestration | Apache Airflow | Apache 2.0 | Scheduling and pipeline runs |
| Warehouse | PostgreSQL | PostgreSQL License | Storage for raw and modelled data |
| Transformation | dbt Core + dbt-postgres | Apache 2.0 | Staging, intermediate and marts models, tests, docs |
| Reporting | Evidence | MIT | Report built from SQL and Markdown |
| Packaging | Docker Compose | Apache 2.0 | One command runs the full stack |
| CI | GitHub Actions | Free for public repos | Runs tests and `dbt build` on every push |

## Quick start

Requirements: Docker Desktop (or Docker Engine plus Compose), Git, and about 4 GB of free RAM.

```bash
git clone https://github.com/<your-username>/nl-labour-market-explorer.git
cd nl-labour-market-explorer
./start.sh
```

When the script finishes, it prints the links:

| Service | URL | Login |
|---|---|---|
| Report | http://localhost:3000 | none |
| Airflow UI | http://localhost:8080 | see `.env` |
| dbt docs | http://localhost:8081 | none |

Other commands:

```bash
./status.sh   # health of each service and last pipeline run
./stop.sh     # stop everything, keep data
./reset.sh    # stop and wipe all data for a clean start
```

Note: the first run downloads data from CBS and builds the models, so it takes around 10 minutes.

## Project structure

```
nl-labour-market-explorer/
├── start.sh / stop.sh / reset.sh / status.sh
├── docker-compose.yml
├── .env.example
├── README.md
├── LICENSE                       # MIT
│
├── docker/                       # custom images (Airflow + dbt, report)
├── dags/                         # Airflow pipeline DAG
├── ingestion/                    # CBS client, loader, table config
│   └── config.yml                # CBS table IDs to pull
├── dbt_project/
│   ├── dbt_project.yml
│   ├── profiles.yml              # reads connection from environment
│   ├── packages.yml              # dbt_utils, dbt_expectations
│   ├── models/
│   │   ├── staging/              # one model per CBS table
│   │   ├── intermediate/         # joins on period, region, sector
│   │   └── marts/                # fct_labour_market, dim_* tables
│   ├── seeds/                    # region and sector mappings
│   ├── macros/                   # custom macros
│   ├── tests/                    # custom generic tests
│   └── analyses/
├── report/                       # Evidence project (pages and queries)
├── postgres/init/                # databases, roles, permissions
├── tests/                        # Python unit tests for ingestion
├── docs/                         # architecture, screenshots, decisions
└── .github/workflows/ci.yml      # lint, tests and dbt build
```

## Data quality

- Generic tests: `unique`, `not_null`, `relationships`, `accepted_values`
- Custom generic test and macro
- Source freshness checks on every CBS table
- Row count and value range checks on the marts
- Test results shown on the report's Data quality page

## Design decisions

- **PostgreSQL over DuckDB:** a server database is closer to what most employers run, and it shows you can manage a real database with roles and permissions.
- **Evidence over Superset or Metabase:** reports are code in git, so they exist as soon as the repo is cloned. Superset and Metabase store dashboards in their own metadata database, which makes the one-command setup fragile.
- **Read-only role for the report:** Evidence can only read the `marts` schema, which keeps the consumption layer separate from the pipeline.
- **LocalExecutor:** one Airflow worker without Redis or Celery, which keeps resource use low on a laptop.

Full reasoning and scaling notes are in `docs/decisions.md`.

## Scaling to production

In production I would swap in a managed Airflow service, a cloud warehouse such as Snowflake or BigQuery, and dbt Cloud or a CI-driven dbt job. The models and tests would stay the same.

## Roadmap

- Data contracts with Soda Core as an extra DAG task
- RAGAS evaluation and a Langfuse trace for a question-answering layer over the marts
- Kubernetes deployment (K3s locally)

## Data attribution

Data source: Centraal Bureau voor de Statistiek (CBS), Statistics Netherlands. Check the current reuse terms at [opendata.cbs.nl](https://opendata.cbs.nl) before publishing.

## Licence

MIT. See [LICENSE](LICENSE).