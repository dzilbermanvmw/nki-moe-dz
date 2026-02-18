# Qwen Module Validation and Security Checks

## Overview

The `run-evaluation.sh` script now includes comprehensive validation and security checks for qwen module files before execution. This ensures code quality and prevents malicious code execution.

## Validation Steps

### 1. File Existence Check
Verifies that the specified qwen module file exists in the script directory.

```bash
if [ ! -f "$SCRIPT_DIR/$QWEN_FILE" ]; then
    log_error "Qwen module file not found: $QWEN_FILE"
    exit 1
fi
```

**Error Example:**
```
[ERROR] Qwen module file not found: qwen_custom.py
[ERROR] Expected location: /path/to/nki-moe/qwen_custom.py
```

### 2. File Readability Check
Ensures the file has proper read permissions.

```bash
if [ ! -r "$SCRIPT_DIR/$QWEN_FILE" ]; then
    log_error "Qwen module file is not readable: $QWEN_FILE"
    exit 1
fi
```

### 3. Python3 Syntax Validation
Validates that the file contains valid Python3 syntax using `py_compile`.

```bash
if ! python3 -m py_compile "$SCRIPT_DIR/$QWEN_FILE" 2>/dev/null; then
    log_error "Python syntax validation failed"
    exit 1
fi
```

**What it catches:**
- Syntax errors
- Indentation errors
- Invalid Python constructs
- Unclosed brackets/parentheses

### 4. File Size Check
Enforces a maximum file size of 10MB.

```bash
if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
    log_error "File size exceeds 10MB limit"
    exit 1
fi
```

## Security Checks

### Critical Security Violations (Script Exits)

#### 1. System Command Execution
**Blocked patterns:**
- `os.system()`
- `subprocess.call()`
- `subprocess.run()`
- `subprocess.Popen()`

**Why blocked:** Can execute arbitrary system commands, potentially compromising the host system.

**Example:**
```python
# ✗ BLOCKED
import os
os.system("rm -rf /")

# ✗ BLOCKED
import subprocess
subprocess.run(["curl", "malicious-site.com"])
```

#### 2. Dynamic Code Execution
**Blocked patterns:**
- `eval()`
- `exec()`
- `compile()`

**Why blocked:** Can execute arbitrary code strings, major security risk.

**Example:**
```python
# ✗ BLOCKED
eval("__import__('os').system('ls')")

# ✗ BLOCKED
exec("malicious_code_here")
```

### Security Warnings (Script Continues with Warning)

#### 1. Dangerous Imports
**Flagged imports:**
- `subprocess`
- `os.system`
- `eval`, `exec`, `compile`
- `__import__`
- `pickle`, `shelve`, `marshal`

**Warning message:**
```
[WARN] ⚠ Warning: Potentially dangerous imports detected
[WARN] These may be flagged for security review
```

**Note:** Some imports like `os` are allowed for legitimate use (e.g., `os.path`), but `os.system` is blocked.

#### 2. File I/O Operations
**Flagged patterns:**
- `open()`
- `file()`
- `.write()`
- `.read()`

**Warning message:**
```
[WARN] ⚠ Warning: File I/O operations detected
[WARN] Ensure file operations are necessary and safe
```

**Legitimate use cases:**
- Reading model configuration files
- Loading pre-trained weights
- Saving intermediate results

#### 3. Network Operations
**Flagged patterns:**
- `socket`
- `urllib`
- `requests`
- `http.client`
- `ftplib`

**Warning message:**
```
[WARN] ⚠ Warning: Network operations detected
[WARN] Network access may be restricted during evaluation
```

**Note:** Network access may be blocked in the evaluation environment.

## Validation Output Examples

### Successful Validation
```
[STEP] Validating Qwen Module: qwen.py
[INFO] ✓ File exists: qwen.py
[INFO] ✓ File is readable
[INFO] Validating Python3 syntax...
[INFO] ✓ Python3 syntax is valid
[INFO] Performing security checks...
[INFO] ✓ File size: 45KB
[INFO] ✓ Security checks passed - no issues detected
```

### Validation with Warnings
```
[STEP] Validating Qwen Module: qwen_optimized.py
[INFO] ✓ File exists: qwen_optimized.py
[INFO] ✓ File is readable
[INFO] Validating Python3 syntax...
[INFO] ✓ Python3 syntax is valid
[INFO] Performing security checks...
[WARN] ⚠ Warning: File I/O operations detected
[WARN] Ensure file operations are necessary and safe
[INFO] ✓ File size: 67KB
[WARN] Security checks completed with 1 warning(s)
[WARN] Review warnings above before proceeding
```

### Critical Security Violation
```
[STEP] Validating Qwen Module: malicious.py
[INFO] ✓ File exists: malicious.py
[INFO] ✓ File is readable
[INFO] Validating Python3 syntax...
[INFO] ✓ Python3 syntax is valid
[INFO] Performing security checks...
[ERROR] ✗ SECURITY RISK: System command execution detected
[ERROR] System commands are not allowed in qwen modules
```

### Syntax Error
```
[STEP] Validating Qwen Module: broken.py
[INFO] ✓ File exists: broken.py
[INFO] ✓ File is readable
[INFO] Validating Python3 syntax...
[ERROR] Python syntax validation failed for: broken.py
[ERROR] Please fix syntax errors in your qwen module
  File "broken.py", line 42
    def invalid_function(
                        ^
SyntaxError: unexpected EOF while parsing
```

## Best Practices for Qwen Modules

### ✓ Allowed and Recommended

```python
import torch
import torch.nn as nn
from transformers import AutoModel
from neuronx_distributed_inference.models.config import NeuronConfig

class NeuronQwen3MoeForCausalLM:
    def __init__(self, model_path, config):
        # Model initialization
        pass
    
    def forward(self, input_ids):
        # Model forward pass
        pass
```

### ⚠ Use with Caution (Generates Warnings)

```python
import os  # OK for os.path, but os.system is blocked

# Reading configuration files
with open('config.json', 'r') as f:
    config = json.load(f)

# Saving checkpoints
torch.save(model.state_dict(), 'checkpoint.pt')
```

### ✗ Not Allowed (Script Will Exit)

```python
# System commands
import subprocess
subprocess.run(['ls', '-la'])

# Dynamic code execution
eval("print('hello')")
exec("import os")

# Direct system calls
import os
os.system("echo 'test'")
```

## Bypassing Validation (Not Recommended)

If you need to bypass validation for testing purposes, you can:

1. **Temporarily disable checks** (modify script - not recommended for production)
2. **Use a different evaluation method** (direct Python execution)
3. **Contact competition organizers** for special permissions

**Warning:** Bypassing security checks may result in disqualification from the competition.

## Security Rationale

### Why These Checks?

1. **Protect Infrastructure**: Prevent malicious code from compromising evaluation servers
2. **Fair Competition**: Ensure all submissions are evaluated in a controlled environment
3. **Data Integrity**: Prevent unauthorized access to other teams' data
4. **Resource Protection**: Prevent resource exhaustion or system abuse

### Defense in Depth

These checks are part of a multi-layered security approach:

1. **Pre-execution validation** (this script)
2. **Sandboxed execution environment**
3. **Resource limits** (CPU, memory, time)
4. **Network isolation**
5. **File system restrictions**

## Troubleshooting

### Issue: "Python syntax validation failed"
**Solution:** Run `python3 -m py_compile your_qwen.py` to see detailed syntax errors.

### Issue: "System command execution detected"
**Solution:** Remove all `subprocess`, `os.system`, and similar calls. Use pure Python/PyTorch operations.

### Issue: "Dynamic code execution detected"
**Solution:** Remove `eval()`, `exec()`, and `compile()` calls. Use direct function calls instead.

### Issue: "File size exceeds 10MB limit"
**Solution:** Reduce file size by:
- Removing unnecessary comments
- Splitting into multiple modules
- Removing embedded data (use external files)

### Issue: File I/O warnings but legitimate use
**Solution:** This is just a warning. Document why file I/O is necessary. The script will continue.

## Integration with Competition Platform

When submissions are uploaded to the RoboNKI Leaderboard:

1. **Frontend validation**: Basic file type and size checks
2. **Backend validation**: More thorough security scanning
3. **Evaluation environment**: Sandboxed execution with this script
4. **Post-evaluation**: Results uploaded to S3 and database

## Compliance

All qwen modules must comply with:

1. **Competition Rules**: As specified in CONTEST.md
2. **Code of Conduct**: No malicious code or attempts to cheat
3. **Resource Limits**: Stay within allocated compute resources
4. **Security Policy**: Pass all validation checks

Violations may result in:
- Submission rejection
- Score invalidation
- Disqualification from competition
- Ban from future competitions

---

**Date:** January 30, 2026  
**Version:** 1.0  
**Security Level:** Production
