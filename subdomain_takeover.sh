#!/bin/bash

# Color Codes
GREEN="\e[32m"
WHITE="\e[37m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Check if a file is provided
if [ "$#" -ne 1 ]; then
    echo -e "${RED}Usage: $0 subdomains.txt${RESET}"
    exit 1
fi

SUBDOMAINS_FILE=$1

echo -e "${YELLOW}Checking CNAME records for potential subdomain takeover...${RESET}"
echo "---------------------------------------------------------"

while read -r subdomain; do
    if [ -z "$subdomain" ]; then
        continue
    fi

    # Get CNAME using dig
    cname=$(dig +short CNAME "$subdomain")

    if [ -n "$cname" ]; then
        echo -e "${GREEN}[+] $subdomain -> $cname${RESET}"

        # Check if the CNAME target resolves
        cname_resolves=$(dig +short "$cname")

        if [ -z "$cname_resolves" ]; then
            echo -e "${RED}    [-] Potential Takeover: $cname does not resolve!${RESET}"
            
            # Perform WHOIS lookup on the CNAME target
            whois_info=$(whois "$cname" | grep -E "No match|NOT FOUND|Status: inactive" | head -1)
            
            if [ -n "$whois_info" ]; then
                echo -e "${YELLOW}    [!] WHOIS Check: Domain might be available!${RESET}"
            fi
        else
            echo -e "${GREEN}    [+] CNAME target is active.${RESET}"
        fi
    else
        echo -e "${WHITE}[-] No CNAME found for $subdomain${RESET}"
    fi
done < "$SUBDOMAINS_FILE"

echo "---------------------------------------------------------"
echo -e "${YELLOW}CNAME enumeration completed!${RESET}"
