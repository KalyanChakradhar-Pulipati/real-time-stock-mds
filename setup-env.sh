#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Real-Time Stock MDS - Setup Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python found: $(python3 --version)${NC}"

# Create .env from .env.example
if [ ! -f .env ]; then
    echo -e "${YELLOW}📝 Creating .env from .env.example${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env created${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env with your credentials:${NC}"
    echo -e "${YELLOW}   nano .env${NC}"
else
    echo -e "${GREEN}✅ .env already exists${NC}"
fi

# Setup pre-commit hook
echo -e "${YELLOW}🔐 Setting up pre-commit hook${NC}"
mkdir -p .git/hooks
if [ -f .githooks/pre-commit ]; then
    cp .githooks/pre-commit .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo -e "${GREEN}✅ Pre-commit hook installed${NC}"
else
    echo -e "${YELLOW}⚠️  .githooks/pre-commit not found${NC}"
fi

# Create virtual environment
if [ ! -d venv ]; then
    echo -e "${YELLOW}📦 Creating virtual environment${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${GREEN}✅ Virtual environment already exists${NC}"
fi

# Activate virtual environment
echo -e "${YELLOW}🔄 Activating virtual environment${NC}"
source venv/bin/activate

# Install dependencies
echo -e "${YELLOW}📥 Installing dependencies${NC}"
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1
echo -e "${GREEN}✅ Dependencies installed${NC}"

# Verify environment variables
echo -e "${YELLOW}✔️  Testing environment variable loading${NC}"
python3 -c "from dotenv import load_dotenv; import os; load_dotenv(); print('✅ Env vars loaded successfully')" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not verify env vars${NC}"

# Check .env is in .gitignore
if grep -q "\.env" .gitignore; then
    echo -e "${GREEN}✅ .env is protected in .gitignore${NC}"
else
    echo -e "${RED}❌ .env is NOT in .gitignore${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "${YELLOW}1. Edit .env with your credentials:${NC}"
echo -e "${YELLOW}   nano .env${NC}"
echo ""
echo -e "${YELLOW}2. Add your environment variables:${NC}"
echo -e "${YELLOW}   - SNOWFLAKE_USER${NC}"
echo -e "${YELLOW}   - SNOWFLAKE_PASSWORD${NC}"
echo -e "${YELLOW}   - SNOWFLAKE_ACCOUNT${NC}"
echo -e "${YELLOW}   - FINNHUB_API_KEY${NC}"
echo ""
echo -e "${YELLOW}3. Start Docker services:${NC}"
echo -e "${YELLOW}   docker-compose up -d${NC}"
echo ""
echo -e "${YELLOW}4. Run the producer:${NC}"
echo -e "${YELLOW}   python producer/producer.py${NC}"
echo ""
echo -e "${YELLOW}5. In another terminal, run the consumer:${NC}"
echo -e "${YELLOW}   python consumer/consumer.py${NC}"
echo ""
echo -e "${YELLOW}6. Monitor Airflow at: http://localhost:8080${NC}"
echo ""
echo -e "${GREEN}For more info, read: SETUP.md${NC}"
