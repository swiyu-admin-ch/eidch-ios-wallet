for(( i=0; i<SCRIPT_INPUT_FILE_COUNT; i++ ));
do
  eval file="\$SCRIPT_INPUT_FILE_${i}"
  swiftformat $file
done

