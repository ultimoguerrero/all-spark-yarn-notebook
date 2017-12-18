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

PYSPARK_DRIVER_PYTHON="jupyter" PYSPARK_DRIVER_PYTHON_OPT="notebook --allow-root" $SPARK_HOME/bin/pyspark --queue HighPool --master yarn-client --num-executors 2 --executor-cores 2 --executor-memory 16G --driver-memory 16G --conf spark.yarn.executor.memoryOverhead=4G
