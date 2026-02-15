# AWS Trainium2/3 MoE Kernel Challenge

**MLSys 2026 Competition Track**

Participants will write custom kernels with the Neuron Kernel Interface (NKI) for the Qwen3-30B-A3B Mixture of Experts model and optimize inference performance on AWS Trainium2/3 hardware.

For full details on the competition, read [the competition guidelines](https://github.com/aws-neuron/nki-moe/blob/main/CONTEST.md). 

To register your team, [enter your information here](https://docs.google.com/forms/d/e/1FAIpQLSeWuJ9h9F0-aC5OwhKcIKgzUB8Sc3DFdBNEgzxzHfM4QsajcA/viewform?usp=sharing&ouid=108119140038382966223&resourcekey=0-VVlo6GUSizIcln6HhBFvKQ) (just one entry per team).

## Getting Started

To learn NKI, follow [the official NKI guide](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/general/nki/index.html) and various example NKI kernels from the [nki-samples repository](https://github.com/aws-neuron/nki-samples). Another tool to help with optimizing NKI kernels is [NKI autotune](https://github.com/awslabs/nki-autotune).

## Setup Steps

1. Create a Trainium2 instance with AWS Neuron SDK v2.27 using EC2 based on the [setup guide](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/setup/neuron-setup/multiframework/multi-framework-ubuntu24-neuron-dlami.html#setup-ubuntu24-multi-framework-dlami).
2. Activate the Neuron Python virtual environment to run inference by running the appropriate activation command for your SDK version:
   ```bash
   source /opt/aws_neuronx_venv_pytorch_2_9_nxd_inference/bin/activate
   ```
3. Clone this repository and navigate to its root:
```bash
git clone https://github.com/aws-neuron/nki-moe.git
cd [LOCAL PATH]/nki-moe
```
where `[PATH]` is the directory where you have performed the clone.

4. Download the [HuggingFace Qwen3-30B-A3B model](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct) to a `~/Qwen3-Coder-30B-A3B/hf_model` folder in your home directory. We recommend doing so using the [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/en/guides/cli), you can install Hugging Face CLI by running the following command:
```bash
pip3 install huggingface_hub[cli]
```
The command to download HuggingFace model into the expected `~/Qwen3-30B-A3B/hf_model/` folder should look like:
```bash
hf download Qwen/Qwen3-Coder-30B-A3B-Instruct --local-dir ~/Qwen3-30B-A3B/hf_model/
```

5. To run inference in `generate` mode, navigate to `[PATH]/nki-moe` folder and run the following command:
```bash
python3 main.py --mode generate --model-path ~/qwen-30b-a3b/hf_model --compiled-model-path ~/qwen-30b-a3b/traced_model --prompt "What is the capital of France?"
```
**NOTE:** you may need to install the corresponding version of Transformers library using command like:
```bash
pip install "transformers[hf-cli]==4.56.2"
```

6. To run inference in other modes, please use the new `run-evaluation.sh` script which offers the following command arguments:
```bash
./run-evaluation.sh -h
Usage: ./run-evaluation.sh [OPTIONS]

Required:
  -t, --team-id TEAM_ID          Team identifier (required)
  -m, --member-id MEMBER_ID      Team member identifier (required)

Optional:
  -M, --mode MODE                Evaluation mode (default: evaluate_single)
                                 Options: evaluate_single, evaluate_all, validate, generate
  -p, --platform PLATFORM        Platform target (default: trn2)
                                 Options: trn2, trn3
  -P, --prompt PROMPT            Prompt text (default: "I believe the meaning of life is")
  -s, --seq-len LENGTH           Sequence length (default: 640)
  -q, --qwen-module MODULE       Qwen module name (default: qwen)
                                 Examples: qwen, qwen_optimized, qwen_with_nki
  -a, --target-account-id ID     AWS account ID for S3 bucket (default: 195034363981)
  -S, --submission-id ID         Submission identifier (default: auto-generated timestamp)
  -u, --upload                   Upload results to S3 bucket
  -h, --help                     Show this help message

Examples:
  # Single prompt evaluation on trn2 platform with default prompt
  ./run-evaluation.sh --team-id my_team --member-id john_doe

  # Single prompt evaluation with custom qwen module
  ./run-evaluation.sh -t my_team -m john_doe -q qwen_optimized

  # Single prompt evaluation with S3 bucket upload to custom account
  ./run-evaluation.sh -t my_team -m john_doe -a 123456789012 --upload

  # Evaluate all prompts with custom qwen module
  ./run-evaluation.sh -t my_team -m jane_smith -M evaluate_all -q qwen_with_nki --upload

  # Evaluate single prompt on trn3 platform with custom account
  ./run-evaluation.sh -t my_team -m bob_jones -p trn3 -a 987654321098 --upload
```
As you can see, you can pass arguments like `-t my_team` (team_id),  `-m john_doe` (member_id), `-a 123456789012` AWS account_id for hosting S3 bucket for submissions, `--upload` whther results should be uoploaded to a target S3 buccket and `-q qwen_with_nki` - whether custom NKI kernel can be implemented and integrated with the main script.

## NKI Kernel Development

This repository contains the standard model implementation in `qwen.py`.

Your task is to identify parts of the model (operators, fused operators, layers, or even the whole model) that can be implemented as NKI kernels and add them to create optimized versions of the model.

### Sample NKI Kernels

This repository includes two NKI kernel examples to help you get started:

#### 1. Tensor Add Example (`nki_tensor_add_example.py`)

A simple NKI kernel demonstrating basic tensor operations. This serves as a minimal reference implementation showing:
- Basic NKI kernel structure with `@nki.jit` decorator
- Tensor indexing and loading from HBM to SBUF
- Element-wise operations
- Storing results back to HBM

This example is not integrated into the model but provides a foundation for understanding NKI kernel development.

#### 2. RMSNorm Kernel (`nki_custom_rmsnorm.py`)

A production-ready NKI RMSNorm implementation integrated into the Qwen model. This kernel follows the pattern from the [official AWS NKI RMSNorm tutorial](https://awsdocs-neuron.readthedocs-hosted.com/en/v2.26.0/general/nki/tutorials/rmsnorm.html).


We also have `qwen_with_nki.py` which has model implementation with custom NKI kernels integrated. To test the different implementations:

```bash
# Standard inference (uses qwen.py)
python3 main.py --mode generate --model-path ~/qwen-30b-a3b/hf_model --compiled-model-path ~/qwen-30b-a3b/traced_model --prompt "What is the capital of France?"

# With NKI RMSNorm kernel (uses qwen_with_nki.py)
python3 main.py --mode generate --enable-nki --model-path ~/qwen-30b-a3b/hf_model --compiled-model-path ~/qwen-30b-a3b/traced_model --prompt "What is the capital of France?"
```

**Important:** When switching between NKI and standard modes, remove the traced model directory and compile cache to ensure proper recompilation:
```bash
rm -rf ~/qwen-30b-a3b/traced_model
rm -rf /var/tmp/neuron-compile-cache/*
```

The `--enable-nki` flag in `main.py` controls which model file is loaded:
- Without flag: loads `qwen.py` (standard implementation)
- With flag: loads `qwen_with_nki.py` (NKI-accelerated implementation)

Key areas to focus on:
* MoE routing and expert selection logic
* Expert computation (gate_proj, up_proj, down_proj)
* Attention mechanisms with MoE-specific optimizations
* Memory-efficient tensor operations for sparse expert execution

## Evaluation and Scoring

The contest organizers will execute each team's submission across the twenty withheld benchmarks on a dedicated Trainium instance. The submissions will be evaluated on:

1) Accuracy of generated output vs. our reference implementation. Accuracy evaluation will be a binary assessor: Any benchmark that fails an accuracy threshold will result in a score of 0\.   
2) Latency (Time to first token (TTFT))  
3) Throughput measured as output tokens / second  
4) Amount of model written in NKI (measured as NKI FLOPS / total model FLOPS) (will be applied as a scaling factor for (b) and (c)). Note: NKI FLOPs measures the number of multiply-accumulate (MAC) operations.

Rankings will be established by calculating the total normalized number of points per team, where points are normalized against the baseline.

We define **points** as **Accuracy** (binary) **\* Reduced Latency \* Increased Throughput \* (1 + Normalized NKI FLOPS)**, where:

* **Accuracy** = 1 if accuracy matches or exceeds a predetermined threshold, 0 otherwise  
* **Reduced Latency** = Reference implementation TTFT divided by submission TTFT  
* **Increased Throughput** = Submission tokens/sec divided by reference implementation tokens/sec  
* **Normalized NKI FLOPS** = Submission NKI FLOPS divided by total model FLOPS

For example, a submission that is sufficiently accurate, with 10x reduced latency, 2x increased throughput, and 0.85 normalized NKI FLOPS would obtain 1 \* 10 \* 2 \* 1.85 \= 37 points.

## Additional Tools

1. **Profiling:** If you would like to profile your implementation in order to get a better understanding of performance bottlenecks and opportunities for optimization, you can use the [Neuron Explorer](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/tools/neuron-explorer/index.html).
2. **Benchmarking:** You can also leverage the [NKI benchmarking API](https://awsdocs-neuron.readthedocs-hosted.com/en/latest/general/nki/api/generated/nki.benchmark.html) to retrieve execution latency statistics.

## Contact

**Email**: [nki-mlsys-2026@amazon.com](mailto:nki-mlsys-2026@amazon.com)
