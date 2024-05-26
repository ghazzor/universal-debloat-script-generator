#!/bin/bash

# File paths
DEBLOATED_PACKAGES_FILE="debloated_rom_packages"
PACKAGES_TO_REMOVE_FILE="packages_to_remove"
STOCK_PACKAGES_FILE="stock_rom_packages"
REMOVE_SCRIPT="nuke.sh"
rm -rf $REMOVE_SCRIPT

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
echo "" >> $REMOVE_SCRIPT
echo "echo 'YOU NEED TO BE ROOTED WITH MAGISK'" >> $REMOVE_SCRIPT
echo "" >> $REMOVE_SCRIPT

# Add Mounts
echo "echo 'Mounting as partitions RW'" >> $REMOVE_SCRIPT
export remount='mount -o remount,rw'
echo "$remount /system" >> $REMOVE_SCRIPT
echo "$remount /product" >> $REMOVE_SCRIPT
echo "$remount /prism" >> $REMOVE_SCRIPT
echo "$remount /optics" >> $REMOVE_SCRIPT
echo "$remount /vendor" >> $REMOVE_SCRIPT
echo "" >> $REMOVE_SCRIPT

# Add commands to remove packages to the script
while IFS= read -r package_path
do
    if [[ ! -z "$package_path" ]]; then
        echo "echo \"Removing $package_path\"" >> $REMOVE_SCRIPT
        echo "rm -rf \"$package_path\"" >> $REMOVE_SCRIPT
        echo "" >> $REMOVE_SCRIPT
    fi
done < $PACKAGES_TO_REMOVE_FILE

# Provide execution permission to the generated script
chmod +x $REMOVE_SCRIPT

echo "$REMOVE_SCRIPT has been generated."
