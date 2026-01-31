# run-evaluation.sh Script Update

## Overview

Updated the `run-evaluation.sh` script to support custom qwen modules and dynamic S3 bucket configuration based on AWS account ID.

## Changes Made

### 1. New CLI Arguments

#### `--qwen-module` / `-q`
- **Purpose**: Specify which qwen Python module to use for evaluation
- **Default**: `qwen` (uses qwen.py)
- **Examples**: `qwen`, `qwen_optimized`, `qwen_with_nki`

#### `--target-account-id` / `-a`
- **Purpose**: Specify AWS account ID for S3 bucket construction
- **Default**: `195034363981`
- **Usage**: Constructs S3 bucket name as `nki-moe-leaderboard-dev-submissions-{ACCOUNT_ID}`

### 2. Removed Arguments

#### `--s3-bucket` / `-b`
- **Removed**: This argument is no longer needed
- **Replaced by**: Dynamic bucket construction using `--target-account-id`

### 3. S3 Bucket Construction

The S3 bucket name is now dynamically constructed:

```bash
S3_BUCKET="nki-moe-leaderboard-dev-submissions-${TARGET_ACCOUNT_ID}"
```

**Examples:**
- Account ID `195034363981` → `nki-moe-leaderboard-dev-submissions-195034363981`
- Account ID `123456789012` → `nki-moe-leaderboard-dev-submissions-123456789012`

### 4. Python Command Update

The `--qwen` parameter is now passed to `main.py`:

```bash
PYTHON_CMD="python3 main.py \
    --mode $MODE \
    --team-id $TEAM_ID \
    --member-id $MEMBER_ID \
    --platform-target $PLATFORM \
    --seq-len $SEQ_LEN \
    --qwen $QWEN_MODULE"
```

### 5. Configuration Display

Added new fields to the configuration output:
- **Qwen Module**: Shows which qwen module is being used
- **Account ID**: Shows the AWS account ID (when uploading to S3)

## Usage Examples

### Example 1: Default Qwen Module
```bash
./run-evaluation.sh --team-id my_team --member-id john_doe
# Uses: qwen.py
# S3 Bucket: nki-moe-leaderboard-dev-submissions-195034363981
```

### Example 2: Custom Qwen Module
```bash
./run-evaluation.sh \
  --team-id my_team \
  --member-id john_doe \
  --qwen-module qwen_optimized
# Uses: qwen_optimized.py
# CSV: my_team_qwen3-30b-a3b_qwen_optimized_score_records.csv
```

### Example 3: Custom Qwen Module with S3 Upload
```bash
./run-evaluation.sh \
  --team-id my_team \
  --member-id john_doe \
  --qwen-module qwen_with_nki \
  --upload
# Uses: qwen_with_nki.py
# Uploads to: s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/my_team/john_doe/submission_TIMESTAMP/
```

### Example 4: Custom Account ID
```bash
./run-evaluation.sh \
  --team-id my_team \
  --member-id john_doe \
  --target-account-id 123456789012 \
  --upload
# S3 Bucket: nki-moe-leaderboard-dev-submissions-123456789012
```

### Example 5: Full Custom Configuration
```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id alice \
  --mode evaluate_all \
  --platform trn3 \
  --qwen-module qwen_with_nki \
  --target-account-id 987654321098 \
  --submission-id submission_v2_final \
  --upload
```

## Configuration Output Example

```
[STEP] NKI-MoE Inference performance Evaluation Configuration
==================================
Team ID:       robotics_team
Member ID:     alice
Mode:          evaluate_single
Platform:      trn2
Prompt:        I believe the meaning of life is
Sequence Len:  640
Qwen Module:   qwen_with_nki
Submission ID: submission_20260130_143000
Upload to S3:  true
Account ID:    195034363981
S3 Bucket:     s3://nki-moe-leaderboard-dev-submissions-195034363981
S3 Path:       submissions/robotics_team/alice/submission_20260130_143000/
==================================
```

## Integration with main.py

The script now passes the qwen module to `main.py`, which:
1. Dynamically imports the specified module
2. Uses it for model evaluation
3. Includes the module name in the CSV filename (if not default "qwen")

**Flow:**
```
run-evaluation.sh (--qwen-module qwen_optimized)
    ↓
main.py (--qwen qwen_optimized)
    ↓
importlib.import_module("qwen_optimized")
    ↓
CSV: team_id_qwen3-30b-a3b_qwen_optimized_score_records.csv
```

## S3 Upload Path Structure

```
s3://{bucket}/submissions/{team_id}/{member_id}/{submission_id}/
├── {team_id}_qwen3-30b-a3b_{qwen_module}_score_records.csv
├── benchmark_report.json
└── expected_logits_*.pt (if generated)
```

**Example:**
```
s3://nki-moe-leaderboard-dev-submissions-195034363981/
└── submissions/
    └── robotics_team/
        └── alice/
            └── submission_20260130_143000/
                ├── robotics_team_qwen3-30b-a3b_qwen_with_nki_score_records.csv
                ├── benchmark_report.json
                └── expected_logits_0.pt
```

## Backward Compatibility

### Default Behavior
- Using default values produces the same behavior as before
- Default qwen module: `qwen` (qwen.py)
- Default account ID: `195034363981`

### CSV Filenames
- Default qwen module doesn't add suffix to CSV filename
- Maintains compatibility with existing workflows

### S3 Bucket
- Default account ID produces the same bucket name as before
- Existing S3 paths remain valid

## Benefits

1. **Flexible Module Selection**: Teams can test multiple implementations easily
2. **Multi-Account Support**: Support for different AWS accounts/environments
3. **Clear Tracking**: CSV filenames clearly indicate which implementation was used
4. **Simplified Configuration**: No need to manually specify full bucket names
5. **Consistent Naming**: Bucket naming follows a standard pattern

## Migration Guide

### Old Command
```bash
./run-evaluation.sh \
  --team-id my_team \
  --member-id john_doe \
  --s3-bucket my-custom-bucket \
  --upload
```

### New Command
```bash
./run-evaluation.sh \
  --team-id my_team \
  --member-id john_doe \
  --target-account-id YOUR_ACCOUNT_ID \
  --upload
```

**Note:** The `--s3-bucket` argument has been removed. Use `--target-account-id` instead.

## Testing Checklist

- [ ] Test with default qwen module
- [ ] Test with custom qwen module (e.g., qwen_optimized)
- [ ] Test with default account ID
- [ ] Test with custom account ID
- [ ] Verify CSV filename includes qwen module name
- [ ] Verify S3 bucket name is constructed correctly
- [ ] Verify S3 upload works with custom account
- [ ] Test all evaluation modes (evaluate_single, evaluate_all, validate, generate)
- [ ] Verify backward compatibility with existing workflows

---

**Date:** January 30, 2026  
**Version:** 2.0
