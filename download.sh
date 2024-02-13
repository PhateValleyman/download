# Funkce pro stahování souborů bez použití ncurses dialogu
download() {
    local ssh_key
    ssh_key=~/.ssh/server

    # Barevné proměnné pro zvýraznění výstupu
    green="\e[32m"
    red="\e[31m"
    reset="\e[0m"

    case "$1" in
        -v|--version|version)
            echo -e "${green}download v1.1${reset}"
            echo -e "${green}by PhateValleyman${reset}"
            echo -e "${green}Jonas.Ned@outlook.com${reset}"
            return
            ;;
        -h|--help|help)
            echo -e "${green}Použití: download SOUBOR [VOLBA]${reset}"
            echo
            echo -e "${green}Stáhne soubor z aktuální SSH relace nebo ho odešle na jiné zařízení.${reset}"
            echo
            echo -e "${green}Volby:${reset}"
            echo -e "${green}  -r, --remote, remote   Odešle soubor na jiné zařízení.${reset}"
            echo -e "${green}  -v, --version, version Zobrazí informace o verzi.${reset}"
            echo -e "${green}  -h, --help, help       Zobrazí tuto nápovědu.${reset}"
            return
            ;;
    esac

    local file="$1"

    download_from_session() {
        local path
        read -p "Zadejte cestu pro uložení souboru: " path
        if scp -i "$ssh_key" "root@192.168.1.20:$file" "$path"; then
            echo -e "${green}Soubor byl úspěšně stažen do $path${reset}"
        else
            echo -e "${red}Chyba při stahování souboru.${reset}"
        fi
    }

    send_to_device() {
        local send_to
        case "$1" in
            phone) send_to="root@192.168.1.15:/sdcard" ;;
            server) send_to="root@192.168.1.20:/i-data/md0/Downloads" ;;
            pc) send_to="Valleyman@192.168.1.10:Desktop" ;;
            *) echo -e "${red}Neznámé zařízení: $1${reset}"; return ;;
        esac
        if scp -i "$ssh_key" "$file" "$send_to"; then
            echo -e "${green}Soubor byl úspěšně odeslán na $1${reset}"
        else
            echo -e "${red}Chyba při odesílání souboru na $1.${reset}"
        fi
    }

    case "$2" in
        -r|--remote|remote)
            send_to_device "$3"
            ;;
        *)
            download_from_session
            ;;
    esac
}
