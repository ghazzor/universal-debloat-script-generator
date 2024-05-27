#!/bin/bash

# File paths
DEBLOATED_PACKAGES_FILE="debloated_rom_packages"
PACKAGES_TO_REMOVE_FILE="packages_to_remove"
STOCK_PACKAGES_FILE="stock_rom_packages"
REMOVE_SCRIPT="nuke.sh"

# Clean up previous files
rm -rf $REMOVE_SCRIPT $PACKAGES_TO_REMOVE_FILE

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
mount /system_root
mount /vendor
mount /product
mount /optics
mount /prism
mount -o remount,rw /system_root
else
mount -o remount,rw /
fi
mount -o remount,rw /product
mount -o remount,rw /prism
mount -o remount,rw /optics
mount -o remount,rw /vendor
echo ' '

EOF

# Add commands to remove packages to the script
while IFS= read -r package_path; do
    if [[ -n "$package_path" ]]; then
        if [[ $package_path == /system/* ]]; then
            cat << EOF >> $REMOVE_SCRIPT
if [ -d /system_root/system ]; then
   rm -rf "/system_root$package_path"
else
   rm -rf "$package_path"
fi
EOF
        else
            echo "rm -rf \"$package_path\"" >> $REMOVE_SCRIPT
        fi
        echo "echo \"Removed $package_path\"" >> $REMOVE_SCRIPT
        echo "" >> $REMOVE_SCRIPT
    fi
done < $PACKAGES_TO_REMOVE_FILE

# Provide execution permission to the generated script
chmod +x $REMOVE_SCRIPT

echo "$REMOVE_SCRIPT has been generated."
