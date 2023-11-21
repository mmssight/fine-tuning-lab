#! /usr/bin/env bash

set -ex

LR=2e-3
NUM_GPUS=1
MAX_SEQ_LEN=2048
MAX_STEP=1000
GRAD_ACCUMULARION_STEPS=16

DATESTR=`date +%Y%m%d-%H%M%S`
RUN_NAME=hotel_lora
OUTPUT_DIR=output/${RUN_NAME}-${DATESTR}
mkdir -p $OUTPUT_DIR

BASE_MODEL_PATH=/autodl-tmp/chatglm3-6b

CUDA_VISIBLE_DEVICES=0 python main_lora.py \
    --do_train \
    --do_eval \
    --do_predict \
    --train_file ../data/train.jsonl \
    --validation_file ../data/dev.jsonl \
    --test_file ../data/test.jsonl \
    --max_seq_length $MAX_SEQ_LEN \
    --preprocessing_num_workers 1 \
    --model_name_or_path $BASE_MODEL_PATH \
    --output_dir $OUTPUT_DIR \
    --per_device_train_batch_size 1 \
    --per_device_eval_batch_size 1 \
    --gradient_accumulation_steps $GRAD_ACCUMULARION_STEPS \
    --max_steps $MAX_STEP \
    --overwrite_cache \
    --predict_with_generate \
    --evaluation_strategy steps \
    --eval_steps 1000 \
    --logging_steps 1 \
    --logging_dir $OUTPUT_DIR/logs \
    --save_steps 200 \
    --learning_rate $LR \
    --lora_rank 8 \
    --lora_alpha 32 \
    --lora_dropout 0.1 2>&1 | tee ${OUTPUT_DIR}/train.log