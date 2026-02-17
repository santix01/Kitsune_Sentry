#!/bin/bash

# ==============================================================================
# KITSUNE SENTRY - URL Reputation Scanner
# ISO 27001 Proof of Concept (Control A.16.1)
#
# Author:  Santiago Avendaño López
# License: MIT
# Version: 1.0
# ==============================================================================

# Configuration
# Replace "YOUR_API_KEY_HERE" with your actual VirusTotal API Key
VT_API_KEY="YOUR_API_KEY_HERE"

# Colors
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
RED='\033[0;31m'
RED_BOLD='\033[1;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Dependency Check
check_dependencies() {
    local missing=0
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is not installed.${NC}"
        missing=1
    fi
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is not installed.${NC}"
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        echo -e "${WHITE}Please install dependencies:${NC}"
        echo -e "  sudo apt install curl jq"
        exit 1
    fi
}

# ASCII Art & Banner
show_banner() {
    echo -e "${PURPLE}"
    echo "      .::.                  .::."
    echo "    .:::::..              ..:::::."
    echo "   /:::_  _\\\            //_  _:::\\"
    echo "   |::|/ \/ \|          |/ \/ \|::|"
    echo "    \\: \  /  /__________\  /  / :/"
    echo "     '-\_/_/    KITSUNE   \\_\\_/-'"
    echo "       '/:.     SENTRY     .:\\' "
    echo "         '::.              .::'"
    echo "            'THREAT  INTEL'"
    echo -e "${NC}"
    echo "============================================"
    echo -e "    ${PURPLE}v1.0 - ISO 27001 Control A.16.1${NC}"
    echo "============================================"
    echo ""
}

# Main Logic
main() {
    check_dependencies
    show_banner

    if [ -z "$1" ]; then
        echo -e "${WHITE}Usage: $0 <url>${NC}"
        exit 1
    fi

    # Check if API Key is set
    if [ "$VT_API_KEY" == "YOUR_API_KEY_HERE" ]; then
        echo -e "${RED}Error: Please set your VirusTotal API Key in the script.${NC}"
        echo -e "${WHITE}Open the script and replace 'YOUR_API_KEY_HERE' with your key.${NC}"
        exit 1
    fi

    local url="$1"
    
    # URL Encoding for VirusTotal (Base64 without padding)
    local url_id=$(echo -n "$url" | base64 | tr -d '=' | tr '+/' '-_')

    echo -e "${WHITE}Scanning: $url${NC}"
    echo -e "${PURPLE}Querying VirusTotal...${NC}"

    # API Request
    local response=$(curl --silent --request GET \
        --url "https://www.virustotal.com/api/v3/urls/$url_id" \
        --header "x-apikey: $VT_API_KEY")

    # Check for curl errors or empty response
    if [ -z "$response" ]; then
        echo -e "${RED}Error: No response from VirusTotal.${NC}"
        exit 1
    fi

    # Check for API errors
    if echo "$response" | jq -e '.error' > /dev/null 2>&1; then
        local err_msg=$(echo "$response" | jq -r '.error.message')
        echo -e "${RED}API Error: $err_msg${NC}"
        exit 1
    fi

    # Parse Results
    local malicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.malicious // 0')
    local harmless=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.harmless // 0')
    local suspicious=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.suspicious // 0')
    local undetected=$(echo "$response" | jq -r '.data.attributes.last_analysis_stats.undetected // 0')

    echo -e "\n${WHITE}--- REPORT SUMMARY ---${NC}"
    
    if [ "$malicious" -gt 0 ] 2>/dev/null; then
        echo -e "${RED_BOLD}DANGER: [X] Security vendors flagged this URL.${NC}"
        echo -e "${RED}Malicious:  $malicious${NC}"
    else
        echo -e "${GREEN}CLEAN: No threats detected.${NC}"
        echo -e "${GREEN}Malicious:  $malicious${NC}"
    fi
    
    echo -e "${WHITE}Harmless:   $harmless${NC}"
    echo -e "${WHITE}Suspicious: $suspicious${NC}"
    echo -e "${WHITE}Undetected: $undetected${NC}"
}

main "$@"
