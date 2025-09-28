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
2. In the Binance website, click the **Deposit** button in the top right corner of the Binance website
3. Choose **Deposit Crypto**
4. In the **Select Coin** dropdown, choose `USDT`
5. In the **Select Network** dropdown, choose `BSC`
6. A deposit address will be generated for you, copy the 42 bytes long address starting with `0x` (e.g., `0x0a328fb948ea4e69df4bf008163923a720ad60f5`)

### Setup Your Payment Address

1. [Go to Payment Settings in KoalaVault](https://www.koalavault.ai/payment-settings)
2. Enter your **Payment Address** you got from the previous step
3. Click **Save**

You can now start to [deploy models as a buyer](#deploy-models-as-a-buyer) or [publish your own models as a seller](#publish-models-as-a-seller).

## Publish Models as a Seller

### Step 1: Install `koava` Tool

Install the koava command-line tool with HuggingFace CLI support:

```bash
pip install koava[huggingface]
```

This will install both `koava` and the HuggingFace CLI tools needed for model downloading.

### Step 2: Authentication Setup

**Generate API Key:**
1. [Go to API Keys Management](https://www.koalavault.ai/api-keys)
2. Click **Generate API Key**
3. Copy the API key. **This is the only time you will see the API key.**

**Login to koava with your API key:**
```bash
koava login
# Enter your KoalaVault API key when prompted
```

**Login to HuggingFace CLI:**
Get your token at [HuggingFace Settings](https://huggingface.co/settings/tokens) (choose `Write` access)

```bash
hf auth login
# Enter your HuggingFace token when prompted
```

**Verify authentication status:**
```bash
koava status
```

This will show your authentication status for both `koava` and HuggingFace CLI.

### Step 3: Download Model from HuggingFace

Download a model to your local directory (e.g., [Qwen3-4B](https://huggingface.co/Qwen/Qwen3-4B)):

```bash
# Download the model using HuggingFace CLI
hf download Qwen/Qwen3-4B --local-dir ./qwen3-4b
```

### Step 4: Push Model to KoalaVault with `koava`

Use the `koava push` command to encrypt and upload your model:

```bash
# Push the model (this will create, encrypt, and upload)
koava push ./qwen3-4b --name "my-qwen3-4b" --description "My encrypted Qwen3-4B model for conversational AI"
```

The `koava push` command will:
1. Create a model entry on both KoalaVault and HuggingFace
2. Retrieve the user-specific signature keys and model-specific master keys from the KoalaVault
3. Encrypt and sign the model files to KoalaVault format 
4. Upload the encrypted files to HuggingFace and headers to KoalaVault

### Step 5: Set Pricing and Publish

1. Visit [KoalaVault.ai](https://www.koalavault.ai)
2. Find your just pushed model in **My Models**
3. Set pricing and publish your model

## Deploy Models as a Buyer

1. [Browse the marketplace](https://www.koalavault.ai/models)
2. Purchase models using your configured payment address
3. Download and use purchased models




