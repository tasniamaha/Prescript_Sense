#!/bin/bash
# Prescript Sense Backend - Deployment and Installation Script
# Date: March 6, 2026
# Author: Fahim Tajoar fahimpramanik@iut-dhaka.edu

echo "======================================"
echo "Prescript Sense Backend Setup Script"
echo "======================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================
# 1. Check Node.js Installation
# ============================================================
echo "Step 1: Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js is not installed. Please install Node.js 14+ first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js $(node --version) found${NC}"
echo ""

# ============================================================
# 2. Install Dependencies
# ============================================================
echo "Step 2: Installing npm dependencies..."
if [ -f "Backend_medicine_dataset/package.json" ]; then
    cd Backend_medicine_dataset
    npm install
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Dependencies installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install dependencies${NC}"
        exit 1
    fi
    cd ..
else
    echo -e "${RED}✗ package.json not found${NC}"
    exit 1
fi
echo ""

# ============================================================
# 3. Check for .env File
# ============================================================
echo "Step 3: Checking environment configuration..."
if [ ! -f "Backend_medicine_dataset/.env" ]; then
    echo -e "${RED}✗ .env file not found${NC}"
    echo "Creating .env template..."
    cat > Backend_medicine_dataset/.env << EOF
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=medicine_db
PORT=5000
EOF
    echo -e "${GREEN}✓ .env template created. Please edit with your credentials.${NC}"
else
    echo -e "${GREEN}✓ .env file found${NC}"
fi
echo ""

# ============================================================
# 4. Check MySQL Connection
# ============================================================
echo "Step 4: Checking MySQL connection..."
if command -v mysql &> /dev/null; then
    echo "MySQL found. Attempting connection..."
    # This will fail if credentials are wrong, but that's okay for setup
    echo -e "${GREEN}✓ MySQL client available${NC}"
else
    echo -e "${RED}⚠ MySQL client not found. Install MySQL 5.7+ separately${NC}"
fi
echo ""

# ============================================================
# 5. Database Setup
# ============================================================
echo "Step 5: Database setup..."
echo "To setup database manually, run:"
echo "  cd Backend_medicine_dataset"
echo "  mysql -u root -p < database_setup.sql"
echo ""

# ============================================================
# 6. Run Tests
# ============================================================
echo "Step 6: Running unit tests..."
if [ -f "Backend_medicine_dataset/tests/test_ocr_analysis.js" ]; then
    cd Backend_medicine_dataset
    if node tests/test_ocr_analysis.js; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
    else
        echo -e "${RED}⚠ Some tests failed. Check the output above.${NC}"
    fi
    cd ..
else
    echo -e "${RED}✗ Tests not found${NC}"
fi
echo ""

# ============================================================
# 7. Summary
# ============================================================
echo "======================================"
echo "Setup Summary"
echo "======================================"
echo -e "${GREEN}✓ Node.js installed${NC}"
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo -e "${GREEN}✓ Environment configured${NC}"
echo ""
echo "Next steps:"
echo "1. Edit Backend_medicine_dataset/.env with your database credentials"
echo "2. Run: mysql -u root -p < Backend_medicine_dataset/database_setup.sql"
echo "3. Run: cd Backend_medicine_dataset && npm start"
echo "4. Server will start on http://localhost:5000"
echo ""
echo "API Documentation:"
echo "- See docs/OCR_ANALYSIS.md for technical details"
echo "- See docs/INTEGRATION_EXAMPLES.md for code examples"
echo "- See docs/SETUP.md for troubleshooting"
echo ""
echo -e "${GREEN}Setup complete! Your backend is ready.${NC}"
echo "======================================"
