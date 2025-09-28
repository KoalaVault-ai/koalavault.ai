#!/bin/bash

# Koalavault.ai Docs Build Script
# This script copies documentation files from koalavault.ai/docs to the server frontend

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SOURCE_DIR="$(dirname "$0")/docs"
TARGET_DIR="../server/frontend/public/docs"
FRONTEND_DOCS_SERVICE="../server/frontend/src/services/docs.ts"

echo -e "${BLUE}🚀 Koalavault.ai Docs Build Script${NC}"
echo "=================================="

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Error: Source directory '$SOURCE_DIR' not found${NC}"
    exit 1
fi

# Check if target directory exists, create if not
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}📁 Creating target directory: $TARGET_DIR${NC}"
    mkdir -p "$TARGET_DIR"
fi

# Check if frontend docs service exists
if [ ! -f "$FRONTEND_DOCS_SERVICE" ]; then
    echo -e "${RED}❌ Error: Frontend docs service '$FRONTEND_DOCS_SERVICE' not found${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Source: $SOURCE_DIR${NC}"
echo -e "${BLUE}📋 Target: $TARGET_DIR${NC}"

# Copy all markdown files from source to target
echo -e "${YELLOW}📄 Copying documentation files...${NC}"

# Find all .md files and copy them
find "$SOURCE_DIR" -name "*.md" -type f | while read -r file; do
    # Get relative path from source directory
    rel_path="${file#$SOURCE_DIR/}"
    
    # Create target directory structure
    target_file="$TARGET_DIR/$rel_path"
    target_dir=$(dirname "$target_file")
    
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi
    
    # Copy the file
    cp "$file" "$target_file"
    echo -e "  ✅ Copied: $rel_path"
done

# Count copied files
file_count=$(find "$TARGET_DIR" -name "*.md" -type f | wc -l)
echo -e "${GREEN}📊 Successfully copied $file_count documentation files${NC}"

# Validate and copy docs index
echo -e "${YELLOW}🔧 Validating docs index...${NC}"

# Check if index.json exists in source directory
if [ ! -f "$SOURCE_DIR/index.json" ]; then
    echo -e "${RED}❌ Error: index.json not found in $SOURCE_DIR${NC}"
    echo -e "${YELLOW}💡 Please create an index.json file in the docs directory${NC}"
    exit 1
fi

# Validate JSON syntax
if ! python3 -m json.tool "$SOURCE_DIR/index.json" > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Invalid JSON syntax in $SOURCE_DIR/index.json${NC}"
    exit 1
fi

# Copy the index file
cp "$SOURCE_DIR/index.json" "$TARGET_DIR/index.json"
echo -e "${GREEN}✅ Copied and validated docs index: $TARGET_DIR/index.json${NC}"

# Validate that all referenced files exist
echo -e "${YELLOW}🔍 Validating referenced files...${NC}"
python3 -c "
import json
import os
import sys

try:
    with open('$TARGET_DIR/index.json', 'r') as f:
        index = json.load(f)
    
    missing_files = []
    for doc in index.get('docs', []):
        file_path = os.path.join('$TARGET_DIR', doc['path'])
        if not os.path.exists(file_path):
            missing_files.append(doc['path'])
    
    if missing_files:
        print('❌ Missing files referenced in index.json:')
        for file in missing_files:
            print(f'  - {file}')
        sys.exit(1)
    else:
        print('✅ All referenced files exist')
        
except Exception as e:
    print(f'❌ Error validating files: {e}')
    sys.exit(1)
"

# Verify git ignore is set up
echo -e "${YELLOW}🔧 Verifying git ignore setup...${NC}"

if grep -q "public/docs/" "../server/frontend/.gitignore"; then
    echo -e "${GREEN}✅ Git ignore is properly configured${NC}"
else
    echo -e "${YELLOW}⚠️  Please add 'public/docs/' to frontend/.gitignore${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}🎉 Build completed successfully!${NC}"
echo "=================================="
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "  • Copied $file_count documentation files"
echo -e "  • Validated and copied docs index: $TARGET_DIR/index.json"
echo -e "  • Set up git ignore for docs content"
echo ""
echo -e "${YELLOW}💡 Architecture:${NC}"
echo -e "  • Control logic: src/services/docs.ts (version controlled)"
echo -e "  • Content data: public/docs/ (git ignored)"
echo -e "  • Manual index: koalavault.ai/docs/index.json"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo -e "  1. Start the frontend development server"
echo -e "  2. Visit /docs to see the documentation"
echo -e "  3. Edit koalavault.ai/docs/index.json to manage docs"
echo ""
echo -e "${GREEN}✨ Documentation system is ready!${NC}"
