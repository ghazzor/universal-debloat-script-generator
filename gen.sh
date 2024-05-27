#!/bin/bash

# File paths
DEBLOATED_PACKAGES_FILE="debloated_rom_packages"
PACKAGES_TO_REMOVE_FILE="packages_to_remove"
STOCK_PACKAGES_FILE="stock_rom_packages"
REMOVE_SCRIPT="nuke.sh"
rm -rf $REMOVE_SCRIPT
rm -rf $PACKAGES_TO_REMOVE_FILE

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

# Generate the removal script
echo "#!/system/bin/sh" > $REMOVE_SCRIPT
echo "" >> $REMOVE_SCRIPT

# Display warnings
echo "echo 'WARNING: This script will remove packages from your device.'" >> $REMOVE_SCRIPT
echo "echo '         I am not responsible for bricked devices.'" >> $REMOVE_SCRIPT
echo "echo '         Ensure you have backed up your data.'" >> $REMOVE_SCRIPT
echo "echo ' '" >> $REMOVE_SCRIPT
echo "" >> $REMOVE_SCRIPT
echo "echo 'YOU NEED TO BE ROOTED WITH MAGISK OR RUNNING IN TWRP'" >> $REMOVE_SCRIPT
echo "echo ' '" >> $REMOVE_SCRIPT
echo "" >> $REMOVE_SCRIPT

# Add Mounts
echo "echo 'Mounting partitions as RW'" >> $REMOVE_SCRIPT
echo "if [ -d /system_root/system ]; then" >> $REMOVE_SCRIPT
echo "mount /system_root" >> $REMOVE_SCRIPT
echo "mount /vendor" >> $REMOVE_SCRIPT
echo "mount /product" >> $REMOVE_SCRIPT
echo "mount /optics" >> $REMOVE_SCRIPT
echo "mount /prism" >> $REMOVE_SCRIPT
echo "mount -o remount,rw /system_root" >> $REMOVE_SCRIPT
echo "else" >> $REMOVE_SCRIPT
echo "mount -o remount,rw /" >> $REMOVE_SCRIPT
echo "fi" >> $REMOVE_SCRIPT
echo "mount -o remount,rw /product" >> $REMOVE_SCRIPT
echo "mount -o remount,rw /prism" >> $REMOVE_SCRIPT
echo "mount -o remount,rw /optics" >> $REMOVE_SCRIPT
echo "mount -o remount,rw /vendor" >> $REMOVE_SCRIPT
echo "echo ' '" >> $REMOVE_SCRIPT
echo "" >> $REMOVE_SCRIPT

# Add commands to remove packages to the script
while IFS= read -r package_path
do
    if [[ ! -z "$package_path" ]]; then
        if [[ $package_path == /system/* ]]; then
            echo "if [ -d /system_root/system ]; then" >> $REMOVE_SCRIPT
            echo "rm -rf \"/system_root$package_path\"" >> $REMOVE_SCRIPT
            echo "else" >> $REMOVE_SCRIPT
            echo "rm -rf \"$package_path\"" >> $REMOVE_SCRIPT
            echo "fi" >> $REMOVE_SCRIPT
        else
            echo "rm -rf \"$package_path\"" >> $REMOVE_SCRIPT
        fi
        echo "echo \"Removed $package_path\"" >> $REMOVE_SCRIPT
        echo " " >> $REMOVE_SCRIPT
    fi
done < $PACKAGES_TO_REMOVE_FILE

# Provide execution permission to the generated script
chmod +x $REMOVE_SCRIPT

echo "$REMOVE_SCRIPT has been generated."
