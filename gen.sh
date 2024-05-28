#!/bin/bash

# File paths
DEBLOATED_PACKAGES_FILE="debloated_rom_packages"
PACKAGES_TO_REMOVE_FILE="packages_to_remove"
STOCK_PACKAGES_FILE="stock_rom_packages"
REMOVE_SCRIPT="nuke.sh"
PACKAGES_TO_REPLACE_FILE="packages_to_replace"

# Source the blacklist definitions
source blacklist.sh

# Function to check if a package path is in the APK blacklist
is_blacklisted_apk() {
    local package_path=$1
    for apk in "${BLACKLIST_APKS[@]}"; do
        if [[ $package_path == *"$apk" ]]; then
            return 0 # True, it is blacklisted
        fi
    done
    return 1 # False, it is not blacklisted
}

# Function to check if a package path is in the directory blacklist
is_blacklisted_dir() {
    local package_path=$1
    for dir in "${BLACKLIST_DIRS[@]}"; do
        if [[ $package_path == $dir* ]]; then
            return 0 # True, it is blacklisted
        fi
    done
    return 1 # False, it is not blacklisted
}

# Clean up previous files
rm -rf $REMOVE_SCRIPT $PACKAGES_TO_REMOVE_FILE $PACKAGES_TO_REPLACE_FILE

# Get the list of installed packages from the stock phone
if [ "$SPG" = "1" ]; then
rm -rf $STOCK_PACKAGES_FILE
adb shell pm list packages -f | cut -f 2 -d ":" | cut -f 1 -d "=" > $STOCK_PACKAGES_FILE
fi

# Compare the package lists and identify packages to remove
comm -23 <(sort $STOCK_PACKAGES_FILE) <(sort $DEBLOATED_PACKAGES_FILE) > $PACKAGES_TO_REMOVE_FILE

# Check if required files exist
if [ ! -f "$DEBLOATED_PACKAGES_FILE" ] || [ ! -f "$STOCK_PACKAGES_FILE" ]; then
    echo "Required text files are missing. Aborting."
    exit 1
fi

# Generate the removal script header
cat << 'EOF' > $REMOVE_SCRIPT
#!/system/bin/sh

echo 'WARNING: This script will remove packages from your device.'
echo '         I am not responsible for bricked devices.'
echo '         Ensure you have backed up your data.'
echo ' '
echo 'YOU NEED TO BE ROOTED WITH MAGISK OR RUNNING IN TWRP'
echo ' '

echo 'Mounting partitions as RW'
if [ -d /system_root/system ]; then
mount -o remount,rw /system_root
else
mount -o remount,rw /
fi
mount -o remount,rw /product
mount -o remount,rw /prism
mount -o remount,rw /optics
echo ' '

if [ -d /system_root/system ]; then
    systempath='/system_root'
else
    systempath=''
fi

EOF

# Add commands to remove packages to the script
while IFS= read -r package_path; do
    if [[ -n "$package_path" ]] && ! is_blacklisted_apk "$package_path" && ! is_blacklisted_dir "$package_path"; then
        if [[ $package_path == /system/* ]]; then
            echo "$package_path" >> $PACKAGES_TO_REPLACE_FILE
            echo "rm -rf \"\$systempath$package_path\"" >> $REMOVE_SCRIPT
        else
            echo "/system$package_path" >> $PACKAGES_TO_REPLACE_FILE
            echo "rm -rf \"$package_path\"" >> $REMOVE_SCRIPT
        fi
        echo "echo \"Removed $package_path\"" >> $REMOVE_SCRIPT
        echo "" >> $REMOVE_SCRIPT
    fi

done < $PACKAGES_TO_REMOVE_FILE

echo "$PACKAGES_TO_REPLACE_FILE has been generated."

# Provide execution permission to the generated script
chmod +x $REMOVE_SCRIPT

echo "$REMOVE_SCRIPT has been generated."
