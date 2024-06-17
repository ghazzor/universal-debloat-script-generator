## Universal Debloat Script Generator

This script generates a removal script to clean unnecessary packages from your Android device's stock ROM, based on a comparison with a debloated ROM package list.

### Notice
- You need to manually debloat once, then use this to create a debloat script.
- Alternatively, manually edit `stock_rom_packages` to create `debloated_rom_packages` (refer to step 3 for the adb command to dump the list).
- Use `SPG=1` to regenerate `stock_rom_packages` if needed.
- You might need to format `/data` to make the ROM boot after debloating if you ran it in TWRP.
- If your stock has uses erofs or any read-only fs, just use the list from `packages_to_replace` in a module to systemlessly debloat (module generation coming soon™).

### Prerequisites
- Root access with Magisk or Custom recovery like TWRP.
- A package list from a debloated ROM.
- Backup your data before running the generated script.
- Devices need to have `avb` disabled.
- Basic knowledge of bash and Android.

### Usage

1. **Clone the repository:**
    ```bash
    git clone https://github.com/ghazzor/universal-debloat-script-generator.git
    ```

2. **Populate `debloated_rom_packages`:**

    If not already done, create this file containing the package list from a debloated ROM:
    ```bash
    adb shell pm list packages -f | cut -f 2 -d ":" | cut -f 1 -d "=" > debloated_rom_packages
    ```

3. **Run the script on your local machine:**
    ```bash
    SPG=1 ./gen.sh
    ```
    This assumes your phone is on the stock ROM with all the bloat. `SPG=1` ensures the script populates `stock_rom_packages` using **ADB**.

4. **Edit `blacklist.sh`:**

    You can add **APKs** and **directories** that are to be ignored and run `gen.sh` again. By default, it blacklists `/apex`, `/data`, and `/vendor`.

5. **Flash the ZIP in TWRP/Execute nuke.sh in TERMUX:**

    After running `gen.sh`, a TWRP flashable ZIP will be generated in the `package` directory and `nuke.sh` in the repo directory.

    Transfer the generated ZIP to your device and flash it in TWRP. This will automatically handle mounting and removing the packages.
    
    **OR**

    Execute `nuke.sh` in Termux.

### Warnings
- This script will remove packages from your device. The author is not responsible for any damage.
- Ensure you have backed up your data before running this script.
