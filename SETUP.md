# Real Time Stock Market Data Engineering Project Setup

## Prerequisites

- Python 3.9+
- Docker & Docker Compose
- Git
- Snowflake account
- Finnhub API key (get free at https://finnhub.io/register)

## Local Development Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/KalyanChakradhar-Pulipati/real-time-stock-mds.git
cd real-time-stock-mds
```

### Step 2: Automated Setup (Recommended)

**On macOS/Linux:**
```bash
bash setup-env.sh
```

**On Windows:**
```bash
setup-env.bat
```

The script will:
- Create `.env` file from `.env.example`
- Setup pre-commit hook
- Create Python virtual environment
- Install dependencies
- Display next steps

### Step 3: Manual Setup (If Needed)

**Create virtual environment:**
```bash
# macOS/Linux
python3 -m venv venv
source venv/bin/activate

# Windows
python -m venv venv
venv\Scripts\activate
```

**Create .env file:**
```bash
cp .env.example .env
# Edit with your credentials
nano .env
```

**Install dependencies:**
```bash
pip install -r requirements.txt
```

**Setup pre-commit hook:**
```bash
mkdir -p .git/hooks
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## Environment Variables Configuration

### Snowflake Credentials

1. Go to your Snowflake account
2. Click on your account name (bottom left)
3. Copy the account identifier
4. Add to `.env`:

```env
SNOWFLAKE_USER=your_username
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_ACCOUNT=xy12345.us-east-1
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DB=STOCKS_MDS
SNOWFLAKE_SCHEMA=COMMON
```

### Finnhub API Key

1. Go to https://finnhub.io/register
2. Sign up for free account
3. Navigate to API keys section
4. Copy your API key
5. Add to `.env`:

```env
FINNHUB_API_KEY=your_api_key_here
FINNHUB_BASE_URL=https://finnhub.io/api/v1/quote
```

### MinIO Configuration (Docker Local)

These can be any values for local development:

```env
MINIO_ENDPOINT=http://minio:9000
MINIO_ACCESS_KEY=admin
MINIO_SECRET_KEY=password123
MINIO_BUCKET=bronze-stock-data-bucket
```

### Application Configuration

```env
LOCAL_DIR=/tmp/minio_downloads
STOCK_SYMBOLS=AAPL,GOOGL,MSFT,AMZN,TSLA
```

## Starting the Application

### Start Docker Services

```bash
docker-compose up -d
```

This starts:
- Zookeeper
- Kafka
- MinIO (S3-compatible storage)
- Airflow Webserver (http://localhost:8080)
- Airflow Scheduler
- PostgreSQL

### Run Components

**Terminal 1 - Producer (Fetches stock data):**
```bash
python producer/producer.py
```

**Terminal 2 - Consumer (Saves to MinIO):**
```bash
python consumer/consumer.py
```

**Terminal 3 - Airflow DAG (Loads to Snowflake):**
```bash
# Airflow runs automatically in Docker
# View at http://localhost:8080
# Username: airflow
# Password: airflow
```

### Run DBT Models

```bash
cd dbt_stocks

# Create dbt profile
dbt debug

# Run models
dbt run

# Test models
dbt test

# Generate docs
dbt docs generate
dbt docs serve
```

## Verify Everything Works

```bash
# Test environment variables load
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print('✅ Env vars loaded')"

# Check .env is ignored
git status  # Should NOT show .env

# Test pre-commit hook
echo "PASSWORD=test" >> test.py
git add test.py
git commit -m "test"  # Should fail - that's good!
git reset HEAD test.py && rm test.py

# Test Docker services
docker ps  # Should show running containers

# Test Kafka
docker exec -it kafka kafka-topics --list --bootstrap-server kafka:9092
```

## Security Best Practices

✅ **DO:**
- Store credentials in `.env` (local only)
- Use environment variables in code
- Run pre-commit hook before commits
- Review `git diff --staged` before commits
- Keep `.env.example` as safe template

❌ **DON'T:**
- Commit `.env` file
- Hardcode credentials in code
- Share `.env` file with anyone
- Log sensitive data
- Push credentials to GitHub

## GitHub Secrets for CI/CD

If using GitHub Actions, add secrets:

1. Go to: `Settings > Secrets and variables > Actions`
2. Click "New repository secret"
3. Add these secrets:
   - `SNOWFLAKE_USER`
   - `SNOWFLAKE_PASSWORD`
   - `SNOWFLAKE_ACCOUNT`
   - `FINNHUB_API_KEY`
   - `MINIO_ACCESS_KEY`
   - `MINIO_SECRET_KEY`

Use in workflows:
```yaml
env:
  SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
  SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
```

## Troubleshooting

### Issue: "ModuleNotFoundError: No module named 'dotenv'"
**Solution:**
```bash
pip install python-dotenv
```

### Issue: "No such file or directory: .env"
**Solution:**
```bash
cp .env.example .env
nano .env  # Add your credentials
```

### Issue: "Pre-commit hook prevents commit"
**Solution:** This is working correctly! You tried to commit a credential. Review your changes:
```bash
git diff --staged
# Remove the sensitive data and try again
```

### Issue: Docker services won't start
**Solution:**
```bash
# Check Docker is running
docker ps

# Check logs
docker-compose logs

# Stop and restart
docker-compose down
docker-compose up -d
```

### Issue: "Connection refused" to Snowflake
**Solution:** Verify credentials:
```bash
# Test connection
python -c "
import os
from dotenv import load_dotenv
import snowflake.connector

load_dotenv()

try:
    conn = snowflake.connector.connect(
        user=os.getenv('SNOWFLAKE_USER'),
        password=os.getenv('SNOWFLAKE_PASSWORD'),
        account=os.getenv('SNOWFLAKE_ACCOUNT')
    )
    print('✅ Snowflake connection successful')
    conn.close()
except Exception as e:
    print(f'❌ Connection failed: {e}')
"
```

## Project Structure

```
real-time-stock-mds/
├── .env.example              # Safe credential template
├── .gitignore                # Git ignore rules (protects .env)
├── .githooks/
│   └── pre-commit           # Hook to prevent credential commits
├── requirements.txt          # Python dependencies
├── docker-compose.yml        # Docker services configuration
├── dbt_project.yml          # DBT configuration
├── producer/
│   └── producer.py          # Fetch stock data from Finnhub
├── consumer/
│   └── consumer.py          # Consume Kafka messages, save to MinIO
├── dags/
│   └── minio_to_snowflake.py # Airflow DAG for data loading
├── models/
│   ├── bronze/              # Raw data models
│   ├── silver/              # Cleaned data models
│   └── gold/                # Business logic models
└── SETUP.md                 # This file
```

## Data Flow

```
Finnhub API
    ↓
Producer (producer.py)
    ↓
Kafka Topic: stock_prices
    ↓
Consumer (consumer.py)
    ↓
MinIO: bronze-stock-data-bucket
    ↓
Airflow DAG (minio_to_snowflake.py)
    ↓
Snowflake: STOCKS_MDS.COMMON
    ↓
DBT Models (Bronze → Silver → Gold)
    ↓
Analytics Ready Data
```

## Next Steps

1. ✅ Complete setup using `setup-env.sh` or `setup-env.bat`
2. ✅ Fill in `.env` with your credentials
3. ✅ Start Docker: `docker-compose up -d`
4. ✅ Run producer: `python producer/producer.py`
5. ✅ Run consumer: `python consumer/consumer.py`
6. ✅ Monitor Airflow: http://localhost:8080
7. ✅ View DBT docs: `dbt docs serve`

## Support

For issues or questions:
1. Check Troubleshooting section
2. Review logs: `docker-compose logs -f`
3. Check environment variables: `env | grep SNOWFLAKE`
4. Create an issue on GitHub

---

**Happy data engineering! 🚀**
