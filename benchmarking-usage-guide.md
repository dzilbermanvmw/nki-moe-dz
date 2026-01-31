# NKI-MoE Benchmarking Usage Guide

## Overview

The `main.py` script is the primary driver for the NKI (Neuron Kernel Interface) contest benchmarking system. It evaluates Qwen3-30B-A3B Mixture-of-Experts models on AWS Trainium accelerators, measuring performance, accuracy, and NKI kernel optimization.

## Table of Contents

- [Execution Modes](#execution-modes)
- [CLI Arguments Reference](#cli-arguments-reference)
- [Usage Examples](#usage-examples)
- [Scoring System](#scoring-system)
- [Output Files](#output-files)

---

## Execution Modes

The script supports five primary modes via the `--mode` argument:

### 1. `generate`
Generate text outputs using the model without evaluation.

### 2. `validate`
Validate model accuracy against baseline by comparing logits (Trn3 only).

### 3. `evaluate_single`
Run a complete evaluation on a single prompt including:
- Accuracy check (Trn3) or skip accuracy (Trn2)
- Performance benchmarking
- NKI FLOPs ratio calculation
- Final score computation

### 4. `evaluate_all`
Evaluate the model across all prompts from `prompts.txt` with corresponding baseline data.

### 5. `generate_accuracy_baselines`
Generate baseline logits for accuracy validation (used for creating reference data).

---

## CLI Arguments Reference

### Contest-Specific Arguments

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--mode` | choice | required | Execution mode: `evaluate_single`, `evaluate_all`, `validate`, `generate`, `generate_accuracy_baselines` |
| `--qwen` | str | `"qwen"` | Python module name containing your custom Qwen model implementation |
| `--enable-nki` | flag | False | Enable NKI kernel optimizations |
| `--base-latency` | float | 526.15 | Baseline latency in ms for score calculation |
| `--base-throughput` | float | 134.61 | Baseline throughput (tokens/sec) for score calculation |
| `--team-id` | str | None | Team identifier for score tracking (creates team-specific CSV) |
| `--member-id` | str | None | Team member identifier for score tracking |

### Model Configuration

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--model-path` | str | `/home/ubuntu/Qwen3-30B-A3B/hf_model` | Path to HuggingFace model directory |
| `--compiled-model-path` | str | `/home/ubuntu/Qwen3-30B-A3B/traced_model` | Path to save/load compiled Neuron model |
| `--platform-target` | str | `"trn2"` | Target platform: `trn2` or `trn3` |

### Evaluation Parameters

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--benchmark` | flag | False | Enable benchmarking mode |
| `--divergence-difference-tol` | float | 0.001 | Tolerance for logit divergence in accuracy checks |
| `--tol-map` | str | None | Custom tolerance map for accuracy validation |
| `--num-tokens-to-check` | int | None | Limit number of tokens to validate (None = all) |

### Generation Parameters

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--prompt` | str | append | Add a prompt (can be used multiple times) |
| `--top-k` | int | 20 | Top-K sampling parameter |
| `--top-p` | float | 0.95 | Top-P (nucleus) sampling parameter |
| `--temperature` | float | 0.6 | Sampling temperature |
| `--global-topk` | int | None | Global top-K for sampling |
| `--do-sample` | bool | True | Enable sampling during generation |
| `--dynamic` | flag | False | Enable dynamic generation |
| `--pad-token-id` | int | 2 | Padding token ID |

### Basic Configuration

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--torch-dtype` | str | `"bfloat16"` | PyTorch data type: `bfloat16`, `float16`, `float32` |
| `--batch-size` | int | 1 | Batch size (auto-set to number of prompts) |
| `--padding-side` | str | None | Tokenizer padding side: `left` or `right` |
| `--seq-len` | int | 640 | Maximum sequence length |
| `--n-active-tokens` | int | None | Number of active tokens |
| `--n-positions` | int | None | Number of positions |
| `--max-context-length` | int | None | Maximum context length |
| `--max-new-tokens` | int | None | Maximum new tokens to generate |
| `--max-length` | int | None | Maximum total length |
| `--rpl-reduce-dtype` | str | None | Reduce data type for RPL operations |
| `--output-logits` | flag | False | Output logits during generation |
| `--vocab-parallel` | flag | False | Enable vocabulary parallelism |
| `--skip-compile` | bool | False | Skip model compilation (use pre-compiled) |
| `--save_sharded_checkpoint` | bool | True | Save sharded checkpoint |

### Attention Configuration

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--fused-qkv` | flag | False | Enable fused QKV attention |
| `--sequence-parallel-enabled` | flag | False | Enable sequence parallelism |
| `--flash-decoding-enabled` | flag | False | Enable flash decoding |

### On-Device Sampling

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--on-device-sampling` | flag | False | Enable on-device sampling |

### Bucketing Configuration

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--enable-bucketing` | bool | True | Enable bucketing for variable sequence lengths |
| `--bucket-n-active-tokens` | flag | False | Bucket based on active tokens |
| `--context-encoding-buckets` | int[] | None | Context encoding bucket sizes |
| `--token-generation-buckets` | int[] | None | Token generation bucket sizes |

### Parallelism

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--tp-degree` | int | 4 | Tensor parallelism degree |

### Kernel Optimizations

| Argument | Type | Default | Description |
|----------|------|---------|-------------|
| `--qkv-kernel-enabled` | flag | False | Enable custom QKV kernel |
| `--attn-kernel-enabled` | flag | False | Enable custom attention kernel |
| `--mlp-kernel-enabled` | flag | False | Enable custom MLP kernel |
| `--quantized-mlp-kernel-enabled` | flag | False | Enable quantized MLP kernel |
| `--rmsnorm-quantize-kernel-enabled` | flag | False | Enable RMSNorm quantization kernel |
| `--quantized-kernel-lower-bound` | float | 1200.0 | Lower bound for quantized kernel usage |
| `--mlp-kernel-fuse-residual-add` | flag | False | Fuse residual addition in MLP kernel |

---

## Usage Examples

### Example 1: Single Prompt Evaluation (Trn2)

```bash
python main.py \
  --mode evaluate_single \
  --platform-target trn2 \
  --prompt "I believe the meaning of life is" \
  --team-id "team_alpha" \
  --member-id "member_001" \
  --qwen qwen \
  --enable-nki
```

### Example 2: Single Prompt Evaluation with Accuracy Check (Trn3)

```bash
python main.py \
  --mode evaluate_single \
  --platform-target trn3 \
  --prompt "What is artificial intelligence?" \
  --team-id "team_beta" \
  --member-id "member_002" \
  --qwen qwen \
  --enable-nki \
  --num-tokens-to-check 50
```

### Example 3: Validate Model Accuracy (Trn3 only)

```bash
python main.py \
  --mode validate \
  --platform-target trn3 \
  --prompt "Explain quantum computing" \
  --qwen qwen \
  --divergence-difference-tol 0.001
```

### Example 4: Generate Text Output

```bash
python main.py \
  --mode generate \
  --prompt "Once upon a time" \
  --prompt "In a galaxy far away" \
  --qwen qwen \
  --temperature 0.8 \
  --top-k 50
```

### Example 5: Evaluate All Prompts (Trn2)

```bash
python main.py \
  --mode evaluate_all \
  --platform-target trn2 \
  --team-id "team_gamma" \
  --member-id "member_003" \
  --qwen qwen \
  --enable-nki
```

### Example 6: Custom Model Path and Compilation

```bash
python main.py \
  --mode evaluate_single \
  --model-path /custom/path/to/model \
  --compiled-model-path /custom/path/to/compiled \
  --prompt "Test prompt" \
  --team-id "team_delta" \
  --skip-compile false
```

### Example 7: Advanced Kernel Optimizations

```bash
python main.py \
  --mode evaluate_single \
  --prompt "Advanced optimization test" \
  --enable-nki \
  --qkv-kernel-enabled \
  --attn-kernel-enabled \
  --mlp-kernel-enabled \
  --flash-decoding-enabled \
  --team-id "team_epsilon"
```

### Example 8: Generate Accuracy Baselines

```bash
python main.py \
  --mode generate_accuracy_baselines \
  --qwen baseline_qwen
```

---

## Scoring System

The final score is calculated using the formula:

```
final_score = accuracy × reduced_latency × increased_throughput × (1 + nki_flop_ratio)
```

Where:
- **accuracy**: 1.0 (pass) or 0.0 (fail) for Trn3; always 1.0 for Trn2
- **reduced_latency**: `base_latency / measured_latency`
- **increased_throughput**: `measured_throughput / base_throughput`
- **nki_flop_ratio**: Ratio of NKI FLOPs to total FLOPs (0.0 to 1.0)

### Score Components

1. **Accuracy**: Validates that model outputs match baseline logits within tolerance
2. **Latency**: P99 end-to-end latency in milliseconds
3. **Throughput**: Tokens generated per second
4. **NKI FLOPs Ratio**: Percentage of compute operations using NKI kernels

---

## Output Files

### 1. Benchmark Report (`benchmark_report.json`)

Contains detailed performance metrics:

```json
{
  "e2e_model": {
    "latency_ms_p99": 450.23,
    "throughput": 156.78,
    "latency_ms_mean": 445.12,
    "latency_ms_p50": 443.89
  },
  "context_encoding_model": { ... },
  "token_generation_model": { ... }
}
```

### 2. Score Records CSV

Team-specific CSV file: `{team_id}_qwen3-30b-a3b_score_records.csv`

Or default: `qwen3-30b-a3b_score_records.csv`

Columns:
- `team_id`: Team identifier
- `member_id`: Member identifier
- `base_latency`: Baseline latency (ms)
- `base_throughput`: Baseline throughput (tokens/sec)
- `accuracy`: Accuracy score (0 or 1)
- `latency`: Measured latency (ms)
- `throughput`: Measured throughput (tokens/sec)
- `nki_flop_ratio`: NKI FLOPs ratio
- `increased_throughput`: Throughput improvement factor
- `reduced_latency`: Latency improvement factor
- `final_score`: Computed final score
- `timestamp`: Evaluation timestamp

### 3. Expected Logits (Baseline Generation Mode)

Files: `expected_logits_{i}.pt` (PyTorch tensor files)

---

## Important Notes

### Platform Differences

- **Trn2**: Accuracy validation is skipped (always 1.0)
- **Trn3**: Full accuracy validation against baseline

### Default Prompt

If no `--prompt` is specified, the default prompt is:
```
"I believe the meaning of life is"
```

### Tolerance Map

Default tolerance map (auto-set):
```python
{None: (1e-5, 0.05), 1000: (1e-5, 0.03), 50: (1e-5, 0.03), 5: (1e-5, 0.03)}
```

### HLO Files

The script automatically locates HLO (High-Level Optimizer) files in:
- Context encoding: `/tmp/nxd_model/context_encoding_model/_tp0_bk0`
- Token generation: `/tmp/nxd_model/token_generation_model/_tp0_bk0`

### Required Files for `evaluate_all` Mode

- `prompts.txt`: List of prompts (one per line)
- `prompt_data_trn2.txt` or `prompt_data_trn3.txt`: Baseline data for each prompt

---

## Troubleshooting

### Common Issues

1. **Missing prompts.txt**: Required for `evaluate_all` mode
2. **HLO files not found**: Ensure model compilation completed successfully
3. **Validation not supported on Trn2**: Use `--platform-target trn3` for validation mode
4. **Out of memory**: Reduce `--batch-size` or `--seq-len`

### Performance Tips

1. Use `--skip-compile true` after first compilation to save time
2. Enable `--enable-nki` for better NKI FLOPs ratio
3. Use kernel optimizations (`--mlp-kernel-enabled`, etc.) for better performance
4. Adjust `--tp-degree` based on available Neuron cores

---

## Quick Reference

### Minimal Evaluation Command

```bash
python main.py --mode evaluate_single --team-id YOUR_TEAM --member-id YOUR_ID
```

### Full Optimization Command

```bash
python main.py \
  --mode evaluate_single \
  --platform-target trn2 \
  --enable-nki \
  --qkv-kernel-enabled \
  --attn-kernel-enabled \
  --mlp-kernel-enabled \
  --flash-decoding-enabled \
  --team-id YOUR_TEAM \
  --member-id YOUR_ID
```

---

## Additional Resources

- See `CONTEST.md` for contest rules and guidelines
- See `README.md` for setup instructions
- See `qwen.py` for model implementation details
- See `test.py` for helper functions
