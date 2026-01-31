# NKI-MoE Evaluation Runner Guide

## Overview

`run-evaluation.sh` is a wrapper script that simplifies running NKI-MoE model evaluations with team and member tracking. It automatically handles execution, monitors progress, and displays results from the CSV score records.

## Quick Start

```bash
# Basic usage
./run-evaluation.sh --team-id my_team --member-id john_doe

# With custom prompt
./run-evaluation.sh -t my_team -m john_doe -P "The future of AI is"

# Evaluate all prompts
./run-evaluation.sh -t my_team -m jane_smith -M evaluate_all
```

## Command Line Options

### Required Parameters

| Option | Short | Description | Example |
|--------|-------|-------------|---------|
| `--team-id` | `-t` | Team identifier | `my_team` |
| `--member-id` | `-m` | Team member identifier | `john_doe` |

### Optional Parameters

| Option | Short | Description | Default | Options |
|--------|-------|-------------|---------|---------|
| `--mode` | `-M` | Evaluation mode | `evaluate_single` | `evaluate_single`, `evaluate_all`, `validate`, `generate` |
| `--platform` | `-p` | Platform target | `trn2` | `trn2`, `trn3` |
| `--prompt` | `-P` | Prompt text | `"I believe the meaning of life is"` | Any string |
| `--seq-len` | `-s` | Sequence length | `640` | Any integer |
| `--submission-id` | `-S` | Submission identifier | Auto-generated timestamp | Any string |
| `--s3-bucket` | `-b` | S3 bucket name | `nki-moe-leaderboard-dev-submissions-195034363981` | Any S3 bucket |
| `--upload` | `-u` | Upload results to S3 | `false` | Flag (no value) |
| `--help` | `-h` | Show help message | - | - |

## Usage Examples

### Example 1: Single Evaluation (Default)

```bash
./run-evaluation.sh --team-id robotics_team --member-id alice
```

**What it does:**
- Runs single prompt evaluation
- Uses default prompt
- Platform: trn2
- Creates/updates `robotics_team_score_records.csv`

### Example 2: Custom Prompt

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id bob \
  --prompt "Optimize robot path planning for"
```

### Example 3: Evaluate All Prompts

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id charlie \
  --mode evaluate_all
```

**What it does:**
- Reads prompts from `prompts.txt`
- Evaluates each prompt
- Records all scores to CSV
- Shows total score at end

### Example 4: Trainium 3 Platform

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id diana \
  --platform trn3
```

**Note:** trn3 includes accuracy validation against baseline

### Example 5: Validation Mode

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id eve \
  --mode validate
```

**What it does:**
- Validates model accuracy
- Compares against baseline
- Does not record scores

### Example 6: Short Form

```bash
./run-evaluation.sh -t team1 -m member1 -M evaluate_all -p trn3
```

### Example 7: Upload Results to S3

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id alice \
  --upload
```

**What it does:**
- Runs evaluation
- Uploads CSV file to S3
- Uploads benchmark report (if exists)
- Uploads logit files (if exist)
- S3 path: `s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_TIMESTAMP/`

### Example 8: Custom Submission ID with S3 Upload

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id bob \
  --submission-id submission_v2_optimized \
  --upload
```

**What it does:**
- Uses custom submission ID instead of timestamp
- S3 path: `s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/bob/submission_v2_optimized/`

### Example 9: Custom S3 Bucket

```bash
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id charlie \
  --s3-bucket my-custom-leaderboard-bucket \
  --upload
```

## Output

The script provides comprehensive output including:

### 1. Configuration Display

```
[STEP] NKI-MoE Evaluation Configuration
==================================
Team ID:       robotics_team
Member ID:     alice
Mode:          evaluate_single
Platform:      trn2
Prompt:        I believe the meaning of life is
Sequence Len:  640
==================================
```

### 2. Execution Progress

```
[INFO] Starting evaluation at 2026-01-28 14:30:00
[STEP] Executing evaluation...
[INFO] Command: python3 main.py --mode evaluate_single ...
```

### 3. Completion Status

```
[INFO] Evaluation completed successfully
[INFO] Execution time: 5m 23s
```

### 4. CSV File Information

```
[STEP] Score Records File
==================================
[RESULT] File: robotics_team_score_records.csv
[RESULT] Location: /path/to/nki-moe/robotics_team_score_records.csv
[RESULT] Size: 2.3K
[RESULT] Lines: 15
[RESULT] Last Modified: 2026-01-28 14:35:23
```

### 5. CSV Structure

```
[STEP] CSV Structure
==================================
team_id,member_id,base_latency,base_throughput,accuracy,latency,throughput,nki_flop_ratio,increased_throughput,reduced_latency,final_score,timestamp
```

### 6. Recent Records

```
[STEP] Recent Records (Last 5)
==================================
robotics_team  alice  526.15  134.61  1.0  480.23  145.32  0.15  1.0796  1.0956  1.3598  2026-01-28 14:35:23
robotics_team  bob    526.15  134.61  1.0  465.12  150.21  0.18  1.1159  1.1312  1.4892  2026-01-28 13:20:15
...
```

### 7. Member-Specific Records

```
[STEP] Records for Team: robotics_team, Member: alice
==================================
robotics_team  alice  526.15  134.61  1.0  480.23  145.32  0.15  1.0796  1.0956  1.3598  2026-01-28 14:35:23
robotics_team  alice  526.15  134.61  1.0  475.10  147.50  0.16  1.0958  1.1074  1.4201  2026-01-28 12:10:45

[RESULT] Found 2 record(s) for this team member
```

### 8. Performance Summary

```
[STEP] Performance Summary
==================================
Min Score: 1.3598
Max Score: 1.4201
Avg Score: 1.3900
Total Runs: 2
```

### 9. View Options

```
[STEP] View Options
==================================
View full CSV file:
  cat /path/to/nki-moe/robotics_team_score_records.csv

View in column format:
  column -t -s ',' < /path/to/nki-moe/robotics_team_score_records.csv | less -S

Open in Excel/Numbers:
  open /path/to/nki-moe/robotics_team_score_records.csv
```

### 10. S3 Upload (if --upload flag used)

```
[STEP] Uploading Results to S3
==================================
[INFO] Uploading CSV file to S3...
[INFO] Destination: s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_20260128_143523/robotics_team_score_records.csv
[INFO] ✓ CSV file uploaded successfully
[INFO] Uploading benchmark report to S3...
[INFO] ✓ Benchmark report uploaded successfully

[RESULT] S3 Upload Summary
==================================
[RESULT] Bucket: nki-moe-leaderboard-dev-submissions-195034363981
[RESULT] Path: submissions/robotics_team/alice/submission_20260128_143523/
[RESULT] Files uploaded:
[RESULT]   - robotics_team_score_records.csv
[RESULT]   - benchmark_report.json

[INFO] View uploaded files:
  aws s3 ls s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_20260128_143523/

[INFO] Download files:
  aws s3 cp s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_20260128_143523/ . --recursive
```

## CSV File Format

The script creates/updates a CSV file named `{team_id}_score_records.csv` with the following columns:

| Column | Description | Example |
|--------|-------------|---------|
| `team_id` | Team identifier | `robotics_team` |
| `member_id` | Team member identifier | `alice` |
| `base_latency` | Baseline latency (ms) | `526.15` |
| `base_throughput` | Baseline throughput | `134.61` |
| `accuracy` | Model accuracy | `1.0` |
| `latency` | Measured latency (ms) | `480.23` |
| `throughput` | Measured throughput | `145.32` |
| `nki_flop_ratio` | NKI FLOP ratio | `0.15` |
| `increased_throughput` | Throughput improvement | `1.0796` |
| `reduced_latency` | Latency improvement | `1.0956` |
| `final_score` | Final calculated score | `1.3598` |
| `timestamp` | Execution timestamp | `2026-01-28 14:35:23` |

## Error Handling

The script includes comprehensive error handling:

### Missing Required Parameters

```bash
./run-evaluation.sh --team-id my_team
# Error: Member ID is required
```

### Python Not Found

```bash
# If python3 is not installed
[ERROR] python3 is not installed or not in PATH
```

### Evaluation Failure

```bash
[ERROR] Evaluation failed with exit code 1
# Script exits with same error code
```

### Missing CSV File

```bash
[WARN] CSV file not found: my_team_score_records.csv
[INFO] The file may not have been created if evaluation failed
```

## Integration with Leaderboard

The CSV files generated by this script can be automatically uploaded to the leaderboard S3 bucket for ingestion.

### Automatic S3 Upload

```bash
# Upload results automatically after evaluation
./run-evaluation.sh \
  --team-id robotics_team \
  --member-id alice \
  --upload
```

**S3 Path Structure:**
```
s3://nki-moe-leaderboard-dev-submissions-195034363981/
└── submissions/
    └── {team_id}/
        └── {member_id}/
            └── {submission_id}/
                ├── {team_id}_score_records.csv
                ├── benchmark_report.json
                └── expected_logits_*.pt (if generated)
```

**Example:**
```
s3://nki-moe-leaderboard-dev-submissions-195034363981/
└── submissions/
    └── robotics_team/
        └── alice/
            └── submission_20260128_143523/
                ├── robotics_team_score_records.csv
                ├── benchmark_report.json
                └── expected_logits_0.pt
```

### Prerequisites for S3 Upload

1. **AWS CLI installed:**
   ```bash
   # Check if installed
   aws --version
   
   # Install if needed (macOS)
   brew install awscli
   
   # Install if needed (Linux)
   pip3 install awscli
   ```

2. **AWS credentials configured:**
   ```bash
   # Configure credentials
   aws configure
   
   # Or use environment variables
   export AWS_ACCESS_KEY_ID=your_access_key
   export AWS_SECRET_ACCESS_KEY=your_secret_key
   export AWS_DEFAULT_REGION=us-east-2
   ```

3. **S3 bucket permissions:**
   - Read/Write access to the submissions bucket
   - IAM policy example:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "s3:PutObject",
           "s3:GetObject",
           "s3:ListBucket"
         ],
         "Resource": [
           "arn:aws:s3:::nki-moe-leaderboard-dev-submissions-195034363981",
           "arn:aws:s3:::nki-moe-leaderboard-dev-submissions-195034363981/*"
         ]
       }
     ]
   }
   ```

### Manual Upload (Alternative)

If you prefer manual upload or the automatic upload fails:

1. **Upload CSV file:**
   ```bash
   aws s3 cp robotics_team_score_records.csv \
     s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_001/
   ```

2. **Upload all result files:**
   ```bash
   aws s3 sync . \
     s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_001/ \
     --exclude "*" \
     --include "*_score_records.csv" \
     --include "benchmark_report.json" \
     --include "expected_logits_*.pt"
   ```

3. **Verify upload:**
   ```bash
   aws s3 ls s3://nki-moe-leaderboard-dev-submissions-195034363981/submissions/robotics_team/alice/submission_001/
   ```

### Leaderboard Processing

Once uploaded to S3, the leaderboard system will:

1. **Detect new submissions** via S3 event notifications
2. **Parse CSV files** to extract scores and metrics
3. **Validate data** against schema requirements
4. **Update rankings** in real-time
5. **Trigger notifications** to team members
6. **Archive results** for historical tracking

## Advanced Usage

### Batch Processing Multiple Members

```bash
#!/bin/bash
TEAM_ID="robotics_team"
MEMBERS=("alice" "bob" "charlie" "diana")

for member in "${MEMBERS[@]}"; do
  echo "Evaluating for $member..."
  ./run-evaluation.sh -t "$TEAM_ID" -m "$member" -M evaluate_all
  echo "---"
done
```

### Automated Testing

```bash
#!/bin/bash
# Run evaluation and check if score improved

TEAM_ID="test_team"
MEMBER_ID="test_member"
CSV_FILE="${TEAM_ID}_score_records.csv"

# Get previous best score
PREV_BEST=$(tail -n +2 "$CSV_FILE" 2>/dev/null | \
  awk -F',' '{print $11}' | \
  sort -rn | \
  head -1)

# Run evaluation
./run-evaluation.sh -t "$TEAM_ID" -m "$MEMBER_ID"

# Get new score
NEW_SCORE=$(tail -1 "$CSV_FILE" | awk -F',' '{print $11}')

# Compare
if (( $(echo "$NEW_SCORE > $PREV_BEST" | bc -l) )); then
  echo "✓ Score improved: $PREV_BEST → $NEW_SCORE"
else
  echo "✗ Score did not improve: $NEW_SCORE ≤ $PREV_BEST"
fi
```

### Continuous Integration

```yaml
# .github/workflows/evaluate.yml
name: NKI-MoE Evaluation

on:
  push:
    branches: [ main ]

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Evaluation
        run: |
          cd nki-moe
          ./run-evaluation.sh \
            --team-id ${{ github.repository_owner }} \
            --member-id ${{ github.actor }} \
            --mode evaluate_single
      - name: Upload Results
        uses: actions/upload-artifact@v2
        with:
          name: score-records
          path: nki-moe/*_score_records.csv
```

## Troubleshooting

### Issue: Script not executable

```bash
chmod +x run-evaluation.sh
```

### Issue: Python dependencies missing

```bash
pip3 install -r requirements.txt
```

### Issue: CSV file permissions

```bash
chmod 644 *_score_records.csv
```

### Issue: Column command not found (macOS)

The script uses `column` for formatting. It's built-in on macOS and most Linux distributions.

### Issue: stat command differences

The script handles both macOS (`stat -f`) and Linux (`stat -c`) formats automatically.

## Performance Tips

1. **Use evaluate_single for quick tests**: Faster than evaluate_all
2. **Run on Trainium instances**: Much faster than CPU
3. **Batch evaluations**: Run multiple members sequentially
4. **Monitor resources**: Check GPU/Trainium utilization

## Security Considerations

1. **CSV files contain performance data**: Not sensitive but should be backed up
2. **Team/Member IDs**: Use consistent naming conventions
3. **File permissions**: Ensure CSV files are readable by leaderboard service
4. **S3 uploads**: Use IAM roles with minimal permissions

## Related Files

- `main.py` - Main evaluation script
- `prompts.txt` - Prompt list for evaluate_all mode
- `prompt_data_trn2.txt` - Baseline data for trn2
- `prompt_data_trn3.txt` - Baseline data for trn3
- `MEMBER-ID-UPDATE.md` - Documentation for member_id feature

---

**Version:** 1.0  
**Last Updated:** January 28, 2026  
**Maintained By:** NKI-MoE Team
