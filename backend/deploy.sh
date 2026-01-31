#!/bin/bash

# Investify Backend Deployment Script
# Run this on your DigitalOcean droplet

set -e

echo "🚀 Starting Investify Backend Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/opt/investify-backend"
NODE_VERSION="20"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Updating system packages...${NC}"
apt update && apt upgrade -y

echo -e "${YELLOW}Step 2: Installing Node.js ${NODE_VERSION}...${NC}"
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt install -y nodejs

echo -e "${YELLOW}Step 3: MongoDB Atlas Configuration...${NC}"
echo -e "${GREEN}Using MongoDB Atlas (cloud-hosted)${NC}"
echo "Make sure to:"
echo "  1. Create a cluster at https://cloud.mongodb.com"
echo "  2. Add your droplet's IP to the Network Access whitelist"
echo "  3. Copy your connection string to the .env file"

echo -e "${YELLOW}Step 4: Installing Nginx...${NC}"
apt install -y nginx

echo -e "${YELLOW}Step 5: Installing PM2...${NC}"
npm install -g pm2

echo -e "${YELLOW}Step 6: Creating application directory...${NC}"
mkdir -p $APP_DIR
mkdir -p $APP_DIR/logs

echo -e "${YELLOW}Step 7: Installing Certbot for SSL...${NC}"
apt install -y certbot python3-certbot-nginx

echo -e "${GREEN}✅ Basic setup complete!${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Copy your backend code to $APP_DIR"
echo "2. Create .env file in $APP_DIR (use .env.example as template)"
echo "3. Copy firebase-service-account.json to $APP_DIR"
echo "4. Run: cd $APP_DIR && npm install"
echo "5. Set up Nginx: cp nginx.conf.example /etc/nginx/sites-available/investify"
echo "6. Edit /etc/nginx/sites-available/investify with your domain"
echo "7. Enable site: ln -s /etc/nginx/sites-available/investify /etc/nginx/sites-enabled/"
echo "8. Get SSL cert: certbot --nginx -d api.your-domain.com"
echo "9. Start app: cd $APP_DIR && pm2 start src/server.js --name investify"
echo "10. Save PM2 config: pm2 save && pm2 startup"
echo ""
echo -e "${GREEN}Done! 🎉${NC}"
