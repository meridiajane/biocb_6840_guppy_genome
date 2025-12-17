source /programs/miniconda3/bin/activate btk_env
export BTK_ROOT=/programs/blobtoolkit-2.6.3

$BTK_ROOT/blobtools2/blobtools host --port 8009 \
    --api-port 8010 \
    --hostname $HOSTNAME \
    --viewer $BTK_ROOT/viewer \
    /local/storage/Blob_Datasets

conda deactivate
