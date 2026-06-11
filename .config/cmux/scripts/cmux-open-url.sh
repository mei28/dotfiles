#!/bin/bash
# BROWSER env var handler: route URLs to cmux embedded browser (as new tab)
exec cmux new-surface --type browser --url "$1" --focus true
