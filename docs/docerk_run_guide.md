# vLLM-cryptotensors — Run Guide

The cryptotensors runtime is built on top of the official **vLLM** container to provide inference services for encrypted models.  
With our customization, encrypted models can be securely decrypted inside the container and served in the same way as a standard vLLM deployment.  
To preserve the security of decrypted models, we enforce additional restrictions on how the container must be started.  
The exact startup requirements are outlined below, including which flags must remain immutable and which can be configured by the user.

> **Note:** Items under **Immutable flags** are fixed and must not be modified.  
> Any changes may cause the program to terminate immediately.  
> All other options remain configurable as in the official vLLM image.

---

## Quick start (template)

> Replace the placeholders with your own values when running the command.

```bash
docker run --gpus all --rm -it \
  --network host \
  --read-only \
  --cap-drop ALL --security-opt no-new-privileges \
  --tmpfs /dev/shm:exec,nosuid,nodev \
  --tmpfs /tmp:exec,nosuid,nodev \
  --tmpfs /root/.triton:exec,nosuid,nodev \
  --tmpfs /root/.cache:exec,nosuid,nodev \
  --env BASE_URL <KOALAVAULT_BASE_URL> \
  -v <HOST_MODEL_DIR>:/model \
  --name <CONTAINER_NAME> \
  <IMAGE_NAME>:<TAG> \
  --koalavault-api-key <KOALAVAULT_API_KEY> \
  --koalavault-model <MODEL_OWNER/MODEL_NAME> \
  --model /model \
  --tokenizer /model \
  --port 8000 \
  --host 0.0.0.0 
```

### Immutable flags (must not change)
> To ensure that cryptotensors decryption happens in a secure environment, we enforce strict controls on how the container is launched.  
> These flags must remain unchanged in the startup command. Otherwise, the container will terminate immediately.
- `--read-only`
- `--cap-drop ALL --security-opt no-new-privileges`
- `--tmpfs /dev/shm:exec,nosuid,nodev`
- `--tmpfs /tmp:exec,nosuid,nodev`
- `--tmpfs /root/.triton:exec,nosuid,nodev`
- `--tmpfs /root/.cache:exec,nosuid,nodev`


### Configurable flags (user may change)
These flags can be customized by the user.  
Flags starting with `koalavault-***` are required by the cryptotensors client and must be provided by your administrator or service provider.  
All other configurable options should follow the standard vLLM container conventions. 
- `--env BASE_URL <KOALAVAULT_BASE_URL>` : Cryptotensors server endpoint (optional).
- `-v <HOST_MODEL_DIR>:/model` : Local path to the encrypted model, must be mounted as `/model`.  
- `--name <CONTAINER_NAME>` : Container name (user-defined).  
- `-p <HOST_PORT>:<CONTAINER_PORT>` : Docker port mapping, usually `-p 8000:8000` to expose the service.  
- `<IMAGE_NAME>:<TAG>` : vLLM-cryptotensors image and version.   
- `--koalavault-api-key <KOALAVAULT_API_KEY>` : API key for authentication (optional).  
- `--koalavault-model <MODEL_OWNER/MODEL_NAME>` : Model identifier in format "owner/model_name".  
- `--model /model` : Fixed, do not change.  
- `--tokenizer /model` : Fixed, do not change.  
- `--port <PORT>` : Port exposed by the container (e.g. `8000`).  
- `--host <HOST_IP>` : Host IP to bind (e.g. `0.0.0.0`).  
- `--others` : Other optional flags supported by vLLM.  

---

## Additional Notes

All other requirements and best practices remain the same as the official vLLM container.  
Please refer to the vLLM documentation for further details on system requirements, GPU support, and advanced configuration:

👉 [vLLM Official Documentation](https://docs.vllm.ai/en/stable/deployment/docker.html)
