# Blacklist specific APK names and directories
BLACKLIST_APKS=(
"NetworkStackGoogle.apk"
"NetworkStackGoogle-arm64_v8a.apk"
) # Add your blacklisted APK names here

BLACKLIST_DIRS=(
"/apex"
"/vendor"
"/data"
) # Add your blacklisted dirs here
