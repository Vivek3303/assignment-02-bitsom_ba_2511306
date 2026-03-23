## Storage Systems

To meet the hospital network's diverse goals, a "polyglot persistence" architecture is required, utilizing different storage systems optimized for specific workloads. 

**1. Predict Patient Readmission Risk:** I chose a **Data Lake (e.g., AWS S3)** for this goal. Training predictive AI models requires massive amounts of historical data, including structured EMRs, semi-structured clinical notes, and unstructured discharge summaries. A Data Lake provides cheap, highly scalable storage for raw data, which data scientists can later process using Spark to train readmission models.

**2. Query Patient History in Plain English:** I chose a **Hybrid Temporal GraphRAG Architecture** combining a **Vector Database (pgvector)** and a **Graph Database (Neo4j)**. Traditional RAG (Vector only) struggles with multi-hop logical reasoning across separate documents. To solve this, the Vector DB stores the semantic text embeddings of clinical notes, while the Graph DB stores a "Temporal Knowledge Graph" (mapping Patient -> Diagnosed_With -> Condition -> [Date]). When a doctor asks a complex chronological question, the LLM uses the Graph to connect the logical dots and the Vector DB to retrieve the exact clinical context, ensuring zero-hallucination, time-aware answers.

**3. Generate Monthly Reports:** I chose a **Data Warehouse (e.g., Snowflake)**. Monthly reports on bed occupancy and department costs involve heavy aggregations (`SUM`, `GROUP BY`) over historical data. A columnar data warehouse is explicitly designed for these complex OLAP queries, powering BI dashboards with high performance.

**4. Stream Real-time Vitals from ICU:** I chose a **Time-Series Database (e.g., InfluxDB)** paired with a streaming broker (Apache Kafka). ICU devices generate thousands of data points per second. Traditional relational databases crash under this write-heavy load. A Time-Series database is optimized for rapid, continuous ingestion of timestamped data and allows for instant anomaly detection alerts.

## OLTP vs OLAP Boundary

In this architecture, a strict boundary separates the live hospital operations (OLTP) from the analytical reporting and AI systems (OLAP). 

The **OLTP boundary** encompasses the primary PostgreSQL database handling live patient admissions, and the Time-Series database ingesting live ICU vitals. These systems are optimized for fast, reliable writes and immediate consistency to support day-to-day healthcare delivery. 

The boundary is crossed using an ETL pipeline. This pipeline periodically extracts data from the OLTP systems, cleans it, and loads it into the **OLAP boundary** (Data Warehouse, Data Lake, Vector DB, and Graph DB). This strict separation ensures that running a massive Graph algorithm or training an AI model will never slow down the live systems doctors use to treat patients.

## Trade-offs

A significant trade-off in this bleeding-edge design is the **Complexity of Graph Ingestion (The "Cold Start" Problem)**. Extracting clean Nodes and Edges from messy, unstructured doctor's notes to populate Neo4j is notoriously difficult and brittle compared to simply dumping text into a Vector DB. 

**Mitigation:** To mitigate this, I would implement an **LLM-driven ETL Pipeline**. Instead of writing thousands of rigid RegEx rules to parse medical notes, we would deploy a smaller, fine-tuned Language Model (like Llama-3 or a Medical NER model) during the ETL phase. This model's sole job is to read the incoming EMRs, extract the entities (Patient, Drug, Diagnosis, Date), and automatically construct the JSON relationships to feed the Graph Database, automating the most labor-intensive part of the architecture.
