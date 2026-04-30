#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# ELLORE Deployment Script
# Automatically updates API Gateway URL and Cognito configuration
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on error

# ─────────────────────────────────────────────
# Terminal Colors
# ─────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────
print_header() {
  echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${WHITE}  $1${NC}"
  echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"
}

print_section() {
  echo -e "\n${CYAN}→${NC} ${BOLD}$1${NC}"
}

print_success() {
  echo -e "  ${GREEN}✓${NC} $1"
}

print_info() {
  echo -e "  ${BLUE}ℹ${NC} $1"
}

print_warning() {
  echo -e "  ${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "  ${RED}✗${NC} ${RED}Error:${NC} $1"
}

# ─────────────────────────────────────────────
# Main Script
# ─────────────────────────────────────────────

print_header "ELLORE Deployment Script"

# ─────────────────────────────────────────────
# Step 1: Check if terraform directory exists
# ─────────────────────────────────────────────

if [ ! -d "terraform" ]; then
  print_error "terraform/ directory not found"
  echo "  Make sure you run this script from the project root directory"
  exit 1
fi

# ─────────────────────────────────────────────
# Step 2: Get Terraform Outputs
# ─────────────────────────────────────────────

print_section "Retrieving configuration from Terraform..."
cd terraform

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
  print_error "Terraform not initialized"
  echo "  Run 'terraform init' first"
  exit 1
fi

# Get API Gateway URL
API_URL=$(terraform output -raw api_gateway_invoke_url 2>/dev/null || echo "")

if [ -z "$API_URL" ]; then
  print_error "Could not retrieve API Gateway URL from Terraform"
  echo "  Make sure you have run 'terraform apply' first"
  exit 1
fi

print_success "API Gateway URL: ${CYAN}$API_URL${NC}"

# Get Cognito configuration (optional)
COGNITO_CLIENT_ID=$(terraform output -raw cognito_client_id 2>/dev/null || echo "")
COGNITO_USER_POOL_ID=$(terraform output -raw cognito_user_pool_id 2>/dev/null || echo "")
COGNITO_REGION=$(terraform output -raw cognito_region 2>/dev/null || echo "")

if [ -n "$COGNITO_CLIENT_ID" ] && [ -n "$COGNITO_USER_POOL_ID" ]; then
  print_success "Cognito Client ID: ${CYAN}$COGNITO_CLIENT_ID${NC}"
  print_success "Cognito User Pool: ${CYAN}$COGNITO_USER_POOL_ID${NC}"
  print_success "Cognito Region: ${CYAN}$COGNITO_REGION${NC}"
  COGNITO_CONFIGURED=true
else
  print_info "Cognito not configured (skipping)"
  COGNITO_CONFIGURED=false
fi

cd ..

# ─────────────────────────────────────────────
# Step 3: Update ellore.js with API URL
# ─────────────────────────────────────────────

print_section "Updating ellore.js with API Gateway URL..."

ELLORE_JS="website/ellore.js"

if [ ! -f "$ELLORE_JS" ]; then
  print_error "$ELLORE_JS not found"
  echo "  Make sure website/ellore.js exists"
  exit 1
fi

# Update API_BASE_URL in ellore.js
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s|const API_BASE_URL = '.*';|const API_BASE_URL = '$API_URL';|g" "$ELLORE_JS"
else
  sed -i "s|const API_BASE_URL = '.*';|const API_BASE_URL = '$API_URL';|g" "$ELLORE_JS"
fi

print_success "Updated API_BASE_URL in ellore.js"

# ─────────────────────────────────────────────
# Step 4: Update auth.js with Cognito Config
# ─────────────────────────────────────────────

if [ "$COGNITO_CONFIGURED" = true ]; then
  print_section "Updating auth.js with Cognito configuration..."
  
  AUTH_JS="website/auth.js"
  
  if [ ! -f "$AUTH_JS" ]; then
    print_warning "auth.js not found (skipping Cognito configuration)"
  else
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|UserPoolId: '.*',|UserPoolId: '$COGNITO_USER_POOL_ID',|g" "$AUTH_JS"
      sed -i '' "s|ClientId: '.*',|ClientId: '$COGNITO_CLIENT_ID',|g" "$AUTH_JS"
      sed -i '' "s|Region: '.*'|Region: '$COGNITO_REGION'|g" "$AUTH_JS"
    else
      sed -i "s|UserPoolId: '.*',|UserPoolId: '$COGNITO_USER_POOL_ID',|g" "$AUTH_JS"
      sed -i "s|ClientId: '.*',|ClientId: '$COGNITO_CLIENT_ID',|g" "$AUTH_JS"
      sed -i "s|Region: '.*'|Region: '$COGNITO_REGION'|g" "$AUTH_JS"
    fi
    
    print_success "Updated Cognito configuration in auth.js"
  fi
fi

# ─────────────────────────────────────────────
# Step 5: Get S3 Bucket Name
# ─────────────────────────────────────────────

print_section "Retrieving S3 bucket name..."
cd terraform

S3_BUCKET=$(terraform output -raw website_bucket_name 2>/dev/null || \
            terraform output -raw s3_bucket_name 2>/dev/null || \
            terraform output -raw bucket_name 2>/dev/null || echo "")

if [ -z "$S3_BUCKET" ]; then
  print_error "Could not retrieve S3 bucket name from Terraform"
  cd ..
  exit 1
fi

print_success "S3 Bucket: ${CYAN}$S3_BUCKET${NC}"
cd ..

# ─────────────────────────────────────────────
# Step 6: Sync Website to S3
# ─────────────────────────────────────────────

print_section "Uploading website files to S3..."

if [ ! -d "website" ]; then
  print_error "website/ directory not found"
  exit 1
fi

aws s3 sync website/ s3://$S3_BUCKET/ \
  --exclude ".DS_Store" \
  --exclude "*.backup" \
  --exclude "*.bak" \
  --exclude "*.old" \
  --exclude ".git/*" \
  --delete

print_success "Files uploaded successfully"

# ─────────────────────────────────────────────
# Step 7: Get CloudFront Distribution ID
# ─────────────────────────────────────────────

print_section "Retrieving CloudFront distribution ID..."
cd terraform

CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id 2>/dev/null || \
                terraform output -raw distribution_id 2>/dev/null || echo "")

if [ -z "$CLOUDFRONT_ID" ]; then
  print_error "Could not retrieve CloudFront distribution ID"
  cd ..
  exit 1
fi

print_success "CloudFront ID: ${CYAN}$CLOUDFRONT_ID${NC}"
cd ..

# ─────────────────────────────────────────────
# Step 8: Invalidate CloudFront Cache
# ─────────────────────────────────────────────

print_section "Invalidating CloudFront cache..."

INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_ID \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text 2>/dev/null)

if [ -z "$INVALIDATION_ID" ]; then
  print_warning "Could not create cache invalidation"
  echo "  Cache will clear automatically after ~24 hours"
else
  print_success "Invalidation ID: ${CYAN}$INVALIDATION_ID${NC}"
fi

# ─────────────────────────────────────────────
# Step 9: Get Website URL
# ─────────────────────────────────────────────

print_section "Retrieving website URL..."
cd terraform

WEBSITE_URL=$(terraform output -raw cloudfront_url 2>/dev/null || \
              terraform output -raw website_url 2>/dev/null || echo "")

if [ -z "$WEBSITE_URL" ]; then
  print_warning "Could not retrieve website URL"
  WEBSITE_URL="(check AWS Console for CloudFront URL)"
fi

cd ..

# ─────────────────────────────────────────────
# Deployment Summary
# ─────────────────────────────────────────────

echo ""
print_header "✓ Deployment Successful!"
echo ""
echo -e "${BOLD}Configuration Updated:${NC}"
echo -e "  ${CYAN}•${NC} API Gateway URL: ${GREEN}$API_URL${NC}"

if [ "$COGNITO_CONFIGURED" = true ]; then
  echo -e "  ${CYAN}•${NC} Cognito User Pool: ${GREEN}$COGNITO_USER_POOL_ID${NC}"
  echo -e "  ${CYAN}•${NC} Cognito Client ID: ${GREEN}$COGNITO_CLIENT_ID${NC}"
fi

echo ""
echo -e "${BOLD}Deployment Details:${NC}"
echo -e "  ${CYAN}•${NC} S3 Bucket: ${GREEN}$S3_BUCKET${NC}"
echo -e "  ${CYAN}•${NC} CloudFront ID: ${GREEN}$CLOUDFRONT_ID${NC}"
if [ -n "$INVALIDATION_ID" ]; then
  echo -e "  ${CYAN}•${NC} Invalidation: ${GREEN}$INVALIDATION_ID${NC}"
fi

echo ""
echo -e "${BOLD}Website URL:${NC}"
# Check if URL already has https://
if [[ "$WEBSITE_URL" == https://* ]]; then
  echo -e "  ${PURPLE}🌐${NC} ${GREEN}${BOLD}$WEBSITE_URL${NC}"
else
  echo -e "  ${PURPLE}🌐${NC} ${GREEN}${BOLD}https://$WEBSITE_URL${NC}"
fi

echo ""
echo -e "${YELLOW}Note:${NC} CloudFront cache invalidation takes 2-3 minutes."
echo -e "      Your changes will be visible shortly."
echo ""
echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"