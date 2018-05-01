library(reticulate)
library(here)

reticulate::use_virtualenv("venv")

# Source: https://github.com/tdda/applehealthdata
py_run_file(here::here("data", "export_data.py"))
