## Storage Systems

To meet the hospital network's diverse goals, a "polyglot persistence" architecture is required, utilizing different storage systems optimized for specific workloads. 

**1. Predict Patient Readmission Risk:** I chose a **Data Lake (e.g., AWS S3)** for this goal. Training predictive AI models requires massive amounts of historical data, including structured EMRs (Electronic Medical Records), semi-structured clinical notes, and unstructured discharge summaries. A Data Lake provides cheap, highly scalable storage for raw data in its native format, which data scientists can later process using Spark or Databricks to train the readmission models.

**2. Query Patient History in Plain English:** I chose a **Vector Database (e.g., Pinecone or pgvector)** combined with an LLM (Large Language Model). To allow doctors to search histories semantically (e.g., "Has this patient had a cardiac event?"), traditional keyword search fails. The vector database stores mathematical embeddings of patient records. When a doctor asks a question, the system retrieves the conceptually relevant medical history using a Retrieval-Augmented Generation (RAG) pattern, ensuring accurate, context-aware answers.

**3. Generate Monthly Reports:** I chose a **Data Warehouse (e.g., Snowflake or Google BigQuery)**. Monthly reports on bed occupancy and department costs involve heavy aggregations (`SUM`, `GROUP BY`) over historical data. A columnar data warehouse is explicitly designed for these complex OLAP (Online Analytical Processing) queries, powering BI dashboards (like Tableau or PowerBI) with high performance.

**4. Stream Real-time Vitals from ICU:** I chose a **Time-Series Database (e.g., InfluxDB or TimescaleDB)** paired with a streaming broker (Apache Kafka). ICU devices generate thousands of data points per second (heart rate, oxygen levels). Traditional relational databases crash under this write-heavy load. A Time-Series database is optimized for rapid, continuous ingestion of timestamped data and allows for instant anomaly detection alerts.

## OLTP vs OLAP Boundary

In this architecture, a strict boundary separates the live hospital operations (OLTP) from the analytical reporting and AI systems (OLAP). 

The **OLTP boundary** encompasses the core transactional systems: the primary PostgreSQL database handling live patient admissions and EMR updates, and the Time-Series database ingesting live ICU vitals. These systems are optimized for fast, reliable writes and immediate consistency to support day-to-day healthcare delivery. 

The boundary is crossed using an ETL (Extract, Transform, Load) pipeline (e.g., Apache Airflow or AWS Glue). This pipeline periodically extracts data from the OLTP systems, cleans it, and loads it into the **OLAP boundary**—which consists of the Data Warehouse, the Vector Database, and the Data Lake. This strict separation ensures that running a massive 5-year cost analysis or training an AI model will never slow down the live systems doctors use to treat patients.

## Trade-offs

A significant trade-off in this design is **Architectural Complexity and Maintenance Cost**. By using four distinct storage systems (Relational, Time-Series, Vector, and Warehouse), the hospital requires specialized engineering teams to manage, secure, and monitor each system. Data pipelines between these systems can become brittle, leading to sync issues.

**Mitigation:** To mitigate this, I would heavily leverage a managed cloud ecosystem (like AWS or Azure) to reduce operational overhead. Furthermore, we could consolidate databases; for instance, using a robust PostgreSQL cluster extended with `TimescaleDB` (for ICU vitals) and `pgvector` (for the AI semantic search). This reduces the distinct database engines from four down to two (Postgres + Data Warehouse), drastically simplifying maintenance while retaining the required capabilities.
