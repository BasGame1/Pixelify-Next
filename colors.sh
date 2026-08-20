red() {
 echo -ne "\033[0;31m"
 echo -n "$1"
 echo -e "\033[0m"
}

blue() {
 echo -ne "\033[0;34m"
 echo -n "$1"
 echo -e "\033[0m"
}

green() {
 echo -ne "\033[0;32m"
 echo -n "$1"
 echo -e "\033[0m"
}

yellow() {
 echo -ne "\033[1;33m"
 echo -n "$1"
 echo -e "\033[0m"	
}

info() {
 echo -ne "\033[1;33m"
 echo -n "[INFO] $1"
 echo -e "\033[0m"	
}

success() {
 echo -ne "\033[0;32m"
 echo -n "[SUCCESS] $1"
 echo -e "\033[0m"
}

red() {
 echo -ne "\033[0;31m"
 echo -n "[ERROR] $1"
 echo -e "\033[0m"
}
