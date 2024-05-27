## Universal Debloat Script Generator

This script generates a removal script to clean unnecessary packages from your Android device's stock ROM, based on a comparison with a debloated ROM package list.

### Notice
- You need to manually debloat once, then use this to create a debloat script.
- Alternatively, manually edit `stock_rom_packages` to create `debloated_rom_packages`(refer step 3 for the adb command to dump list).
- Use `SPG=1` to regenerate `stock_rom_packages` if needed.

### Prerequisites
- Root access with Magisk.
- A package list from a debloated ROM.
- Backup your data before running the generated script.

### Usage

1. **Clone the repository:**
    ```bash
    git clone https://github.com/ghazzor/universal-debloat-script-generator.git
    ```

2. **Run the script on your local machine:**
    ```bash
    SPG=1 ./gen.sh
    ```
    This assumes your phone is on the stock ROM with all the bloat. `SPG=1` ensures the script populates `stock_rom_packages` using **ADB**.

3. **Populate `debloated_rom_packages`:**
    If not already done, create this file containing the package list from a debloated ROM:
    ```bash
    adb shell pm list packages -f | cut -f 2 -d ":" | cut -f 1 -d "=" > debloated_rom_packages
    ```

4. **Transfer and execute `nuke.sh` in termux:**
    ```bash
    sh nuke.sh
    ```

### Warnings
- This script will remove packages from your device. The author is not responsible for any damage.
- Ensure you have backed up your data before running this script.
