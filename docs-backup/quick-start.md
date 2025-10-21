# Quick Start Guide

This guide is a quick start guide for users to get started with KoalaVault with toy example.

## Account Setup

### Registration

1. [Register your account in KoalaVault](https://www.koalavault.ai/register)
2. **It is recommended to use the username that is the same as your HuggingFace username.**

### Create Your Crypto Wallet

1. Register a Binance account:
   - **Global**: [binance.com](https://www.binance.com) (serves 140+ countries)
   - **US**: [binance.us](https://www.binance.us) (US-specific platform)
2. [Go to Binance Deposit page](https://www.binance.com/en/my/wallet/account/main/deposit/crypto)(Global) or [binance.us](https://www.binance.us/en/my/wallet/account/main/deposit/crypto)(US) and choose **Deposit Crypto**
3. In the **Select Coin** dropdown, choose `USDT`
4. In the **Select Network** dropdown, choose `BSC`
5. A deposit address will be generated for you, copy the 42 bytes long address starting with `0x` (e.g., `0x0a328fb948ea4e69df4bf008163923a720ad60f5`)

### Setup Your Payment Address

1. [Go to Payment Settings in KoalaVault](https://www.koalavault.ai/payment-settings)
2. Enter your **Payment Address** you got from the previous step
3. Click **Save**

You can now start to [deploy models as a buyer](#deploy-models-as-a-buyer) or [publish your own models as a seller](#publish-models-as-a-seller).

---
## Publish Models as a Seller

### Step 1: Install `koava` Tool

1. Install the koava command-line tool with HuggingFace CLI support:

```bash
pip install -U "koava[huggingface]"
```

### Step 2: Authentication Setup

1. Login to koava with your API key ([Generate API Key](https://www.koalavault.ai/api-keys)):
```bash
koava login
# Enter your KoalaVault API key when prompted
```

2. Login to HuggingFace CLI with your token ([Generate HuggingFace Token](https://huggingface.co/settings/tokens), choose `Write` access)

```bash
hf auth login
# Enter your HuggingFace token when prompted
```

3. Verify authentication status:
```bash
koava status
```

### Step 3: Download Model from HuggingFace

1. Download [Qwen3-0.6B](https://huggingface.co/Qwen/Qwen3-0.6B) to your local directory:

```bash
# Download the model using HuggingFace CLI
hf download Qwen/Qwen3-0.6B --local-dir ./qwen3-0.6b
```

### Step 4: Push Model to KoalaVault with `koava`

1. Encrypt and upload your model to KoalaVault and HuggingFace:

```bash
# Push the model (this will create, encrypt, and upload)
koava push ./qwen3-0.6b
```

> Your full model is hosted on HuggingFace and can be accessed by others using `hf download` command.
> Part of the model is hosted on KoalaVault to control the access to the model, which is available to the paid users.

### Step 5: Set Pricing

1. Visit [KoalaVault.ai](https://www.koalavault.ai)
2. Find your just pushed model in **My Models**
3. In the model page, click **Pricing** then create a new pricing strategy
4. **Remember to publish the pricing strategy to make it effective**

### Step 6: Publish Model

1. After above steps, your model can be published. Click **Publish** in the model page.
2. 🎉 **Congratulations!** Your model is now live and ready to share with the world! 🌟

---

## Deploy Models as a Buyer

> Model owner can always access to the model whether it is published or not. To deploy the model as model owner, directly go to [step 4](#step-4-pull-the-koalavault-enhanced-vllm-docker-image).

### Step 1: Create an Order

1. [Browse the marketplace](https://www.koalavault.ai/models) and find the model you want to purchase
2. In the model page, click **Purchase** in the top right corner
3. In the **Create Order** page, select the pricing plan you prefer
4. ** It is recommended to use the anonymous payment to purchase the model in the first time, which allows you to pay directly from exchanges like Binance without transferring to your registered wallet first. **
5. Click **Create Order**. In the order detail page, you can see the payment instructions and seller's address.

### Step 2: Pay for the Order

1. Copy the **Payment Address** from the order detail page
2. [Go to Binance Deposit page](https://www.binance.com/en/my/wallet/account/main/withdrawal/crypto)(Global) or [binance.us](https://www.binance.us/en/my/wallet/account/main/withdrawal/crypto)(US) and choose **Withdraw Crypto**
3. In the **Select Coin** dropdown, choose `USDT`
4. In the **Withdraw to**, paste the **Payment Address** you copied from the order detail page
5. In the **Select Network** dropdown, choose `BSC`
6. Enter the amount of your order to **Withdraw Amount**
7. Click **Withdraw**
8. Wait for the transaction to be confirmed

### Step 3: Confirm the Order

1. After you get the transaction id from Binance, you can copy the transaction id and paste it to the **Blockchain Transaction ID** field in the order detail page
2. Click **Confirm** in the order detail page. The order will be confirmed by KoalaVault and the model will be available for you to use.

### Step 4: Pull the KoalaVault enhanced vLLM docker image

```bash
docker pull koalavault/vllm-openai
```

### Step 5: Deploy the Model

#### 🚀 Quick Start (Recommended for Beginners)

The simplest way to get started - just run one command and the model will be automatically downloaded:

```bash
docker run --gpus all --rm -it \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  -p 8000:8000 \
  --ipc=host \
  --read-only \
  --cap-drop ALL \
  --tmpfs /tmp:exec,nosuid,nodev \
  koalavault/vllm-openai \
  --koalavault-api-key <KOALAVAULT_API_KEY> \
  --koalavault-model <PUBLISHER_USERNAME>/<MODEL_NAME> \
  --model <PUBLISHER_USERNAME>/<MODEL_NAME>
```

> **Note:** `<PUBLISHER_USERNAME>` is the KoalaVault username of the model publisher (the user who uploaded the model to KoalaVault), not necessarily the HuggingFace organization name.

**Why this method?**
- ✅ **Simplest** - One command, no manual steps
- ✅ **Automatic** - Downloads model on first run
- ✅ **Smart caching** - Reuses downloaded models, resume interrupted downloads
- ✅ **Standard workflow** - Same as using HuggingFace directly

**Important Notes:**
- First run will download the model (takes time depending on model size and network speed)
- Subsequent runs are fast as the model is cached
- Cache directory should not be shared between different users for security

---

#### 🏭 Alternative: Pre-download Model (For Production Environments)

If you prefer full control or need to deploy in production, you can manually download the model first:

**Step 1: Download the Model**

```bash
# Install HuggingFace CLI if you haven't
pip install -U "koava[huggingface]"

# Download the model
hf download <PUBLISHER_USERNAME>/<MODEL_NAME> --local-dir ./<MODEL_NAME>
```

**Step 2: Run Container**

```bash
docker run --gpus all --rm -it \
  -v ./<MODEL_NAME>:/models \
  -p 8000:8000 \
  --ipc=host \
  --read-only \
  --cap-drop ALL \
  --tmpfs /tmp:exec,nosuid,nodev \
  koalavault/vllm-openai \
  --koalavault-api-key <KOALAVAULT_API_KEY> \
  --koalavault-model <PUBLISHER_USERNAME>/<MODEL_NAME> \
  --model /models/<MODEL_NAME>
```

**When to use this method:**
- ✅ Production deployments requiring full control
- ✅ Offline or air-gapped environments
- ✅ Need to verify model files before deployment

---

### Security Notes

> **Important:** To ensure that model decryption happens in a secure environment, we enforce strict controls on how the container is launched.  
> These flags must remain unchanged in the startup command. Otherwise, the container will terminate immediately.

**Required Security Flags:**
- `--read-only` - Container filesystem is read-only
- `--cap-drop ALL` - Drops all Linux capabilities
- `--tmpfs /tmp:exec,nosuid,nodev` - Temporary directory as tmpfs (runtime caches via symlinks)

**Why these restrictions?**
- **Read-only filesystem**: Prevents tampering with system files and persistence of decrypted data
- **Dropped capabilities**: Removes all dangerous permissions (mount, raw sockets, kernel modules, ptrace, etc.). With CapBnd=0x0, processes cannot gain any privileges
- **Host IPC**: Provides sufficient shared memory for large models while maintaining security
- **tmpfs for /tmp**: All runtime caches (Triton, vLLM, PyTorch) are stored in memory via symlinks, ensuring ephemeral storage that disappears when the container stops. The `exec` permission is required for Triton JIT compilation, while `nosuid` and `nodev` prevent privilege escalation attacks





