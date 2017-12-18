#!/bin/sh
# ============================================================
#  Filename: docker-entrypoint.sh
#  Description: Run the jupyter service.
#
#   --ip 0.0.0.0: Allow all IP access.
#   --no-browser: Don't open browser from command line.
#   --notebook-dir: Bunding the workdir.
#
# ===========================================================

PYSPARK_DRIVER_PYTHON="jupyter" PYSPARK_DRIVER_PYTHON_OPT="notebook" $SPARK_HOME/bin/pyspark
