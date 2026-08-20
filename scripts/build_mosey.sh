#!/bin/bash
set -e

# ROOT_DIR is the project root directory
ROOT_DIR=$(pwd)

# First argument is the build directory path, default to out/magisk_module_beta_release
PN_BUILD=${1:-$ROOT_DIR/out/magisk_module_beta_release}

# Check if mosey submodule is present
if [ ! -d "$ROOT_DIR/mosey-p8a" ] || [ ! -f "$ROOT_DIR/mosey-p8a/build_mosey.sh" ]; then
    echo "Warning: mosey-p8a submodule is not cloned or missing build_mosey.sh. Skipping Mosey build."
    exit 0
fi

# Source mosey build scripts
. mosey-p8a/build_mosey.sh || exit 255
. mosey-p8a/wonder/build_wonder.sh || exit 255

WONDER_OUT=$ROOT_DIR/mosey-p8a/out/module
MOSEY_OUT=$ROOT_DIR/mosey-p8a/out/zip

patch_file() {
    FILE=$1
    STUB_NAME=$2
    REPLACE_FILE=$MOSEY_OUT/$FILE
    if [ -f "$PN_BUILD/$FILE" ] && [ -f "$REPLACE_FILE" ]; then
        TEXT_FOR_REPLACE=$(cat "$REPLACE_FILE")
        python3 -c "
import sys
content_file = '$PN_BUILD/$FILE'
with open(content_file, 'r', encoding='utf-8') as f:
    text = f.read()
with open('$REPLACE_FILE', 'r', encoding='utf-8') as f:
    rep = f.read()
new_text = text.replace('$STUB_NAME', rep)
with open(content_file, 'w', encoding='utf-8') as f:
    f.write(new_text)
"
        echo "$FILE patched with Mosey $FILE"
    else
        echo "Warning: $FILE or $REPLACE_FILE not found, skipping patch"
    fi
}

copy_mosey() {
    LIST_NO_CONFLICT_FILES="wonder_mosey_wild.ko"
    LIST_FOLDERS="common payload system"
    
    for i in $LIST_FOLDERS; do
        if [ ! -d "$PN_BUILD/$i" ]; then
            echo "Folder empty on source, creating $PN_BUILD/$i"
            mkdir -p "$PN_BUILD/$i"
        fi
        echo "Copying $i to source"
        rsync -avh "$MOSEY_OUT/$i/" "$PN_BUILD/$i/"
    done

    for i in $LIST_NO_CONFLICT_FILES; do
        if [ -f "$MOSEY_OUT/$i" ]; then
            echo "Copying $i to source"
            mkdir -p "$PN_BUILD/system/vendor/lib/modules"
            cp -f "$MOSEY_OUT/$i" "$PN_BUILD/system/vendor/lib/modules/"
        fi
    done

    # Patch conflict files
    patch_file "customize.sh" "#CUSTOMIZE.SH_MOSEY_STUB"
    patch_file "service.sh" "#SERVICE.SH_MOSEY_STUB"
    patch_file "uninstall.sh" "#UNINSTALLER.SH_MOSEY_STUB"

    # Set built with mosey support flag
    if [ -f "$PN_BUILD/vars.sh" ]; then
        sed -i "s/BUILT_WITH_MOSEY_SUPPORT=0/BUILT_WITH_MOSEY_SUPPORT=1/g" "$PN_BUILD/vars.sh"
    fi
}

module_prop_additions() {
    # Credits
    if [ -f "beta/module/module.prop" ]; then
        if ! grep -q "lok1s" "beta/module/module.prop"; then
            echo -e "\n# Credits to lok1s for mosey\n# He is the original creator of the mosey module" >> beta/module/module.prop
        fi
    fi
}

# Build Wonder if needed
if [ ! -f "$WONDER_OUT/wonder_mosey_wild.ko" ]; then
    echo "Building Wonder"
    build_wonder
    echo "Wonder built!"
else
    echo "Wonder already built, skipping"
fi

# Build Mosey structure if needed
if [ ! -d "$MOSEY_OUT/common" ]; then
    echo "Mosey not found, creating structure"
    cd "$ROOT_DIR/mosey-p8a"
    build_mosey
    cd "$ROOT_DIR"
else
    echo "Mosey in position to copy"
fi

copy_mosey
module_prop_additions
