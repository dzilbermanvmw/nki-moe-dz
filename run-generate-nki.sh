#!/bin/bash
python3 main.py --mode generate --enable-nki --model-path ~/Qwen3-30B-A3B/hf_model/ --compiled-model-path ~/Qwen3-30B-A3B/traced_model --prompt "What is the capital of France?"
