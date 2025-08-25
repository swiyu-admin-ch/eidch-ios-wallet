BUILD_APP_DIR="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app"

# Convert space-separated strings into array
IFS=' ' read -ra CONDITIONS <<< "$SWIFT_ACTIVE_COMPILATION_CONDITIONS"

for CONDITION in "${CONDITIONS[@]}"; do
    if [[ "$CONDITION" == "PROD" ]] || [[ $CONDITION == "ABN" ]]; then
        rm -rf "$BUILD_APP_DIR/Settings.bundle"
    fi
done