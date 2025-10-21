# vLLM-cryptotensors — Run Guide

The cryptotensors runtime is built on top of the official **vLLM** container to provide inference services for encrypted models.  
With our customization, encrypted models can be securely decrypted inside the container and served in the same way as a standard vLLM deployment.  
To preserve the security of decrypted models, we enforce additional restrictions on how the container must be started.  
The exact startup requirements are outlined below, including which flags must remain immutable and which can be configured by the user.

> **Note:** Items under **Immutable flags** are fixed and must not be modified.  
> Any changes may cause the program to terminate immediately.  
> All other options remain configurable as in the official vLLM image.

---

## Deployment Methods

We support two methods for deploying models:

### Method 1: Pre-downloaded Model (Recommended for Production)

Manually download the model to your host machine, then mount it into the container.

```bash
# Step 1: Download model (one-time operation)
hf download <PUBLISHER_USERNAME>/<MODEL_NAME> --local-dir ./model

# Step 2: Run container
docker run --gpus all --rm -it \
  --network host \
  --read-only \
  --cap-drop ALL \
  --ipc=host \
  --tmpfs /tmp:exec,nosuid,nodev \
  --env BASE_URL <KOALAVAULT_BASE_URL> \
  -v ./model:/models \
  --name <CONTAINER_NAME> \
  <IMAGE_NAME>:<TAG> \
  --koalavault-api-key <KOALAVAULT_API_KEY> \
  --koalavault-model <PUBLISHER_USERNAME>/<MODEL_NAME> \
  --model /models \
  --tokenizer /models \
  --port 8000 \
  --host 0.0.0.0
```

**Advantages:**
- Full control over model files
- No repeated downloads
- Suitable for production environments

### Method 2: HuggingFace Cache Auto-download (Convenient for Development)

Use HuggingFace's cache mechanism to automatically download and cache models.

```bash
docker run --gpus all --rm -it \
  --network host \
  --read-only \
  --cap-drop ALL \
  --ipc=host \
  --tmpfs /tmp:exec,nosuid,nodev \
  --env BASE_URL <KOALAVAULT_BASE_URL> \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  --name <CONTAINER_NAME> \
  <IMAGE_NAME>:<TAG> \
  --koalavault-api-key <KOALAVAULT_API_KEY> \
  --koalavault-model <PUBLISHER_USERNAME>/<MODEL_NAME> \
  --model <PUBLISHER_USERNAME>/<MODEL_NAME> \
  --port 8000 \
  --host 0.0.0.0
```

**Advantages:**
- One-step deployment (no manual download)
- Automatic caching and reuse
- Resume interrupted downloads
- Standard HuggingFace workflow

**Important Notes:**
- First run will download the model (may take time depending on model size and network speed)
- Cache directory should not be shared between different users for security reasons
- Only encrypted model files are cached; decryption happens in memory

---

## Security Requirements

### Immutable flags (must not change)

> To ensure that cryptotensors decryption happens in a secure environment, we enforce strict controls on how the container is launched.  
> These flags must remain unchanged in the startup command. Otherwise, the container will terminate immediately.- `--read-only`
- `--cap-drop ALL --security-opt no-new-privileges`
- `--tmpfs /dev/shm:exec,nosuid,nodev`
- `--tmpfs /tmp:exec,nosuid,nodev`
- `--tmpfs /root/.triton:exec,nosuid,nodev`
- `--tmpfs /root/.cache:exec,nosuid,nodev`

- `--read-only`
- `--cap-drop ALL --security-opt no-new-privileges`
- `--tmpfs /dev/shm:exec,nosuid,nodev`
- `--tmpfs /tmp:exec,nosuid,nodev`
- `--tmpfs /root/.triton:exec,nosuid,nodev`
- `--tmpfs /root/.cache:exec,nosuid,nodev`



- `--read-only` - Ensures the container filesystem is read-only
- `--cap-drop ALL` - Drops all Linux capabilities
- `--ipc=host` - Uses host's IPC namespace for shared memory (provides access to host's /dev/shm)
- `--tmpfs /tmp:exec,nosuid,nodev` - Temporary directory as tmpfs (runtime caches via symlinks)

**Why these restrictions?**
- **Read-only filesystem**: Prevents tampering with system files and persistence of decrypted data
- **Dropped capabilities**: Removes all dangerous permissions (mount, raw sockets, kernel modules, ptrace, etc.). With CapBnd=0x0, processes cannot gain any privileges
- **Host IPC**: Provides sufficient shared memory for large models while maintaining security
- **tmpfs for /tmp**: All runtime caches (Triton, vLLM, PyTorch) are stored in memory via symlinks, ensuring ephemeral storage that disappears when the container stops. The `exec` permission is required for Triton JIT compilation, while `nosuid` and `nodev` prevent privilege escalation attacks

### Configurable flags (user may change)

These flags can be customized by the user.  
Flags starting with `koalavault-***` are required by the cryptotensors client and must be provided by your administrator or service provider.  
All other configurable options should follow the standard vLLM container conventions.

#### Model Source Options (choose one):

**Option A: Pre-downloaded model (Method 1)**
- `-v <HOST_MODEL_DIR>:/models` - Local path to the encrypted model, must be mounted as `/models`
- `--model /models` - Path to model inside container
- `--tokenizer /models` - Path to tokenizer inside container (optional)

**Option B: HuggingFace cache (Method 2)**
- `-v ~/.cache/huggingface:/root/.cache/huggingface` - Mount HuggingFace cache directory
- `--model <PUBLISHER_USERNAME>/<MODEL_NAME>` - HuggingFace model identifier (will auto-download)

#### Common Options:

- `--env BASE_URL <KOALAVAULT_BASE_URL>` - Cryptotensors server endpoint (optional)
- `--name <CONTAINER_NAME>` - Container name (user-defined)
- `-p <HOST_PORT>:<CONTAINER_PORT>` - Docker port mapping, usually `-p 8000:8000` to expose the service
- `<IMAGE_NAME>:<TAG>` - vLLM-cryptotensors image and version
- `--koalavault-api-key <KOALAVAULT_API_KEY>` - API key for authentication (required)
- `--koalavault-model <PUBLISHER_USERNAME>/<MODEL_NAME>` - Model identifier in format "publisher_username/model_name" (required, where publisher_username is the KoalaVault username)
- `--port <PORT>` - Port exposed by the container (e.g. `8000`)
- `--host <HOST_IP>` - Host IP to bind (e.g. `0.0.0.0`)
- `--others` - Other optional flags supported by vLLM  

---

## Additional Notes

All other requirements and best practices remain the same as the official vLLM container.  
Please refer to the vLLM documentation for further details on system requirements, GPU support, and advanced configuration:

👉 [vLLM Official Documentation](https://docs.vllm.ai/en/stable/deployment/docker.html)
