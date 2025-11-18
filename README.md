<div align="center">

# 🌊 Kafka to Iceberg Data Pipeline

<p align="center">
  <img src="https://img.shields.io/badge/Apache-Kafka-231F20?style=for-the-badge&logo=apache-kafka&logoColor=white" alt="Kafka">
  <img src="https://img.shields.io/badge/Apache-Flink-E6526F?style=for-the-badge&logo=apache-flink&logoColor=white" alt="Flink">
  <img src="https://img.shields.io/badge/Apache-Iceberg-0099E5?style=for-the-badge&logo=apache&logoColor=white" alt="Iceberg">
  <img src="https://img.shields.io/badge/MinIO-C72E49?style=for-the-badge&logo=minio&logoColor=white" alt="MinIO">
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/DuckDB-FFF000?style=for-the-badge&logo=duckdb&logoColor=black" alt="DuckDB">
  <img src="https://img.shields.io/badge/Hive-FDEE21?style=for-the-badge&logo=apache-hive&logoColor=black" alt="Hive Metastore">
  <img src="https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL">
</p>


</div>

This project demonstrates a real-time data pipeline that streams data from Apache Kafka to Apache Iceberg using Apache Flink SQL. The pipeline processes retail order data and stores it in Iceberg format on MinIO object storage.

## Architecture

The project consists of the following components:

- **Apache Flink** - Stream processing engine for real-time data transformation
- **Apache Kafka** - Message broker for streaming data
- **Apache Iceberg** - Table format for large analytic datasets
- **MinIO** - S3-compatible object storage
- **Hive Metastore** - Metadata management for Iceberg tables
- **PostgreSQL** - Backend database for Hive Metastore
- **ShadowTraffic** - Data generator for realistic retail data
- **Dremio** - Data lake analytics platform
- **PyIceberg** - Python client for Iceberg
- **DuckDB** - In-memory analytical database
- **kcat** - Kafka command-line tool

## Prerequisites

- Docker and Docker Compose
- At least 8GB of available RAM
- [ShadowTraffic](https://shadowtraffic.io/) license (place in `shadowtraffic/license.env`)

## Quick Start

1. **Start all services:**
   ```bash
   docker compose up -d
   ```

2. **Wait for all services to be healthy** (may take 2-3 minutes)

3. **Run the Flink SQL pipeline:**
   ```bash
   docker compose exec -it jobmanager bash -c "./bin/sql-client.sh -f /data/kafka-to-iceberg-new.sql"
   ```

## Data Flow
![image info](img/flowchart.png)

### Catalog Integration

<div align="center">
  
![Catalog Diagram](img/catalog-integration.png)

*Iceberg Catalog Integration: Hive Metastore manages catalog metadata for Flink to access Iceberg tables stored in MinIO*

</div>

To use Iceberg you need to have a catalog metastore. Catalogs in Flink can be a bit complex to understand at first, but this diagram shows how the **Hive Metastore** works as the catalog provider for **Flink** to manage **Iceberg** data and metadata stored in **MinIO** (S3-compatible object store).

## Accessing Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Flink Web UI | http://localhost:8081 | - |
| MinIO Console | http://localhost:9001 | admin/password |
| Dremio | http://localhost:9047 | - |
| Kafka | localhost:9092 | - |
| PostgreSQL | localhost:5432 | hive/hive |

## Connecting MinIO to Dremio

Dremio can query Iceberg tables stored in MinIO object storage. Follow these steps to configure the connection:

### 1. Access Dremio Web UI
- Navigate to http://localhost:9047
- Create an admin account on first login

### 2. Add MinIO as a Data Source

**Step 1: Create S3-Compatible Source**
- Click **"+ Add Source"** in the bottom left corner
- Select **"Amazon S3"** (MinIO is S3-compatible)

**Step 2: Configure Connection**
```
General Settings:
├─ Name: MinIO
├─ AWS Access Key: admin
├─ AWS Secret Key: password
└─ Encrypt Connection: ☐ (uncheck)
```

**Step 3: Add Connection Properties**

Click **"Advanced Options"** and add these properties:
Enable compatibility mode: ☑ (check)
```properties
fs.s3a.path.style.access=true
fs.s3a.endpoint=minio:9000
fs.s3a.connection.ssl.enabled=false
dremio.s3.compat=true
```

**Step 4: Set Root Path (Optional)**
- Under "Advanced Options", set Root Path to: `/warehouse`

**Step 5: Save**
- Click "Save" to create the source

### Important Notes
- MinIO endpoint from within Docker network is `minio:9000` (not `localhost`)
- Path-style access must be enabled for MinIO compatibility
- Default credentials: `admin/password`
- MinIO Console is available at http://localhost:9001 for bucket management

## Troubleshooting

1. **Services not starting**: Ensure you have enough memory and no port conflicts

2. **Flink SQL Error: `java.net.UnknownHostException: hms`**
   
   This error occurs when Flink cannot resolve the Hive Metastore hostname. Common cause on Windows:
   
   **Problem**: The `init-schema.sh` file has Windows line endings (CRLF) instead of Unix line endings (LF)
   
   **Solution**:
   - Open `hms-standalone-postgres/init-schema.sh` in VS Code
   - Check the bottom-right corner of the editor
   - If it shows `CRLF`, click on it and select `LF`
   - Save the file and restart the services:
     ```bash
     docker compose down
     docker compose up -d --build hive-metastore
     ```

3. **Flink SQL errors**: Check that all dependent services are healthy first

4. **Data not flowing**: Verify ShadowTraffic license is valid and placed correctly

5. **Storage issues**: Check MinIO is accessible and warehouse bucket exists

## Cleanup

```bash
docker compose down -v
docker system prune -f
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the pipeline end-to-end
5. Submit a pull request

## License

This project is for educational and demonstration purposes.
