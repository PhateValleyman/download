# Function using ncurses dialog
download-gui() {
    local ssh_key
    ssh_key=~/.ssh/server

    case "$1" in
        -v|--version|version)
            dialog --title "Version" --msgbox "download v1.1\nby PhateValleyman\nJonas.Ned@outlook.com" 10 50
            return
            ;;
        -h|--help|help)
            dialog --title "Help" --msgbox "Usage: download-gui FILE [OPTION]\n\nDownload a file from the current SSH session or send it to another device.\n\nOptions:\n  -r, --remote, remote   Send the file to another device.\n  -v, --version, version Display version information.\n  -h, --help, help       Display this help message." 15 60
            return
            ;;
    esac

    local file="$1"

    create_tmp_dir() {
        ssh -i "$ssh_key" root@192.168.1.15 "[ -d /sdcard/tmp ] || mkdir -p /sdcard/tmp"
        created_tmp_dir=true
    }

    delete_tmp_dir() {
        if [ "$created_tmp_dir" = true ]; then
            ssh -i "$ssh_key" root@192.168.1.15 "rmdir /sdcard/tmp"
            dialog --title "Temporary Directory Deleted" --msgbox "The temporary directory /sdcard/tmp has been deleted." 8 50
        fi
    }

    download_from_session() {
        dialog --title "Download File" --inputbox "Enter the path to save the file:" 10 60 2> /tmp/download_path
        local path
        path=$(< /tmp/download_path)
        if scp -i "$ssh_key" root@192.168.1.20:"$file" "$path"; then
            dialog --title "Downloaded" --msgbox "File successfully downloaded to $path" 8 50
        else
            dialog --title "Error" --msgbox "Error downloading file." 8 40
        fi
        delete_tmp_dir
    }

    send_to_device() {
        local send_to
        case "$1" in
            phone) send_to="root@192.168.1.15:/sdcard" ;;
            server) send_to="root@192.168.1.20:/i-data/md0/Downloads" ;;
            pc) send_to="Valleyman@192.168.1.10:Desktop" ;;
        esac
        if scp -i "$ssh_key" "$file" "$send_to"; then
            dialog --title "Sent" --msgbox "File successfully sent to $1" 8 50
        else
            dialog --title "Error" --msgbox "Error sending file to $1." 8 40
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

# Function without ncurses dialog
download() {
    local ssh_key
    ssh_key=~/.ssh/server

    case "$1" in
        -v|--version|version)
            echo "download v1.1"
            echo "by PhateValleyman"
            echo "Jonas.Ned@outlook.com"
            return
            ;;
        -h|--help|help)
            echo "Usage: download FILE [OPTION]"
            echo
            echo "Download a file from the current SSH session or send it to another device."
            echo
            echo "Options:"
            echo "  -r, --remote, remote   Send the file to another device."
            echo "  -v, --version, version Display version information."
            echo "  -h, --help, help       Display this help message."
            return
            ;;
    esac

    local file="$1"

    download_from_session() {
        read -p "Enter the path to save the file: " path
        if scp -i "$ssh_key" root@192.168.1.20:"$file" "$path"; then
            echo "File successfully downloaded to $path"
        else
            echo "Error downloading file."
        fi
    }

    send_to_device() {
        local send_to
        case "$1" in
            phone) send_to="root@192.168.1.15:/sdcard" ;;
            server) send_to="root@192.168.1.20:/i-data/md0/Downloads" ;;
            pc) send_to="Valleyman@192.168.1.10:Desktop" ;;
        esac
        if scp -i "$ssh_key" "$file" "$send_to"; then
            echo "File successfully sent to $1"
        else
            echo "Error sending file to $1."
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
