# AI News: Step-by-Step Setup Guide

This guide provides a comprehensive walkthrough to deploy and configure the **AI News** agent on Azure. No prior experience with Azure or its services is assumed—every step is explained in detail.

---

## Prerequisites

Before you begin, ensure you have the following:

1. **Azure Subscription**  
   - You need an active Azure subscription. If you don't have one, sign up for a free trial at https://azure.microsoft.com/free.

2. **Azure Command-Line Interface (CLI)**  
   - Install the Azure CLI:  
     - **Windows:** Download and run the MSI installer from https://aka.ms/installazurecliwindows  
     - **macOS:** Run `brew update && brew install azure-cli`  
     - **Linux:** Follow instructions at https://docs.microsoft.com/cli/azure/install-azure-cli-linux  
   - Verify installation:  
     ```bash
     az version
     ```

3. **Python 3.8 or higher**  
   - Install from https://www.python.org/downloads/  
   - Verify installation:  
     ```bash
     python3 --version
     ```

4. **Git**  
   - Install from https://git-scm.com/downloads  
   - Verify installation:  
     ```bash
     git --version
     ```

5. **Code Editor (Recommended)**  
   - Visual Studio Code (https://code.visualstudio.com/) with the “Azure Tools” extension pack.

---

## 1. Clone the Repository

1. Open a terminal or PowerShell window.  
2. Navigate to your development folder:  
   ```bash
   cd ~/projects
   ```  
3. Clone the blueprint repository and enter the agent folder:  
   ```bash
   git clone https://github.com/your-org/azure-ai-agent-service-blueprints.git
   cd azure-ai-agent-service-blueprints/ai-developments-aggregation-agent
   ```

---

## 2. Create an Azure Resource Group

All resources will be grouped together for easy management.

1. Choose a name and location for your resource group, e.g.:  
   - **Name:** `rg-ai-news`  
   - **Location:** `eastus` (or your preferred region)  
2. Create the resource group:  
   ```bash
   az group create      --name rg-ai-news      --location eastus
   ```

---

## 3. Provision a Key Vault

We will store sensitive keys in Azure Key Vault.

1. Create Key Vault:  
   ```bash
   az keyvault create      --name kv-ai-news      --resource-group rg-ai-news      --location eastus
   ```
2. Confirm its creation:  
   ```bash
   az keyvault show --name kv-ai-news
   ```

---

## 4. Store Secrets in Key Vault

Add your Azure OpenAI endpoint and key; Bing Grounding secrets will be added later.

1. **Azure OpenAI Endpoint & Key**  
   ```bash
   az keyvault secret set      --vault-name kv-ai-news      --name OpenAIEndpoint      --value "https://YOUR_OPENAI_RESOURCE_NAME.openai.azure.com/"
   az keyvault secret set      --vault-name kv-ai-news      --name OpenAIKey      --value "YOUR_OPENAI_API_KEY"
   ```

---

## 5. Deploy Azure Resources with Bicep

The `deploy.bicep` file provisions all required Azure resources:

- Storage account  
- App Service Plan  
- Cognitive Services resource for Grounding with Bing  
- Function App  

Run the deployment:

```bash
az deployment group create   --resource-group rg-ai-news   --template-file deploy.bicep   --parameters functionAppName=aiNewsApp
```

> **Note:**  
> - The deployment will output the Function App URL and provision the Bing resource.  
> - It will automatically wire the Bing endpoint and key into the Function App settings once complete.

---

## 6. Configure Local Development Environment

1. **Create and activate a Python virtual environment**  
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate    # macOS/Linux
   .\.venv\Scripts\activate   # Windows PowerShell
   ```

2. **Install Python dependencies**  
   ```bash
   pip install -r requirements.txt
   ```

---

## 7. Create the System Prompt File

1. In the project root, create `system_prompt.txt`.  
2. Paste the following content into it:

   ```
   You are an AI agent named "AI News." Your task is to:
   1. Query Bing News for AI developments reported in the past 24 hours Pacific Time.
   2. Filter out any articles not from the following credible domains: gartner.com, reuters.com, wired.com, mit.edu, stanford.edu.
   3. Prioritize the results in this order:
      a. Articles mentioning both Microsoft and Healthcare.
      b. Articles mentioning both Microsoft and Legal.
      c. Articles mentioning Healthcare alone.
      d. Articles mentioning Legal alone.
   4. Summarize each selected development in one or two sentences, focusing on its implications for the Microsoft ecosystem, Healthcare, and Legal sectors.
   5. Format the final output as a Markdown table with columns: Headline, Date, Summary, Implications, Link. Limit to 10 rows; if more are found, consolidate extras into a single line item.
   6. Do not include any commentary outside the table.
   ```

---

## 8. Retrieve and Set Bing Secrets

1. **Retrieve the Bing Cognitive Service endpoint**  
   ```bash
   az cognitiveservices account show      --name aiNewsApp-bing      --resource-group rg-ai-news      --query "properties.endpoint"      --output tsv
   ```
2. **Retrieve the Bing API key**  
   ```bash
   az cognitiveservices account keys list      --name aiNewsApp-bing      --resource-group rg-ai-news      --query "key1"      --output tsv
   ```
3. **Store them in environment variables for local runs**  
   ```bash
   export BING_SEARCH_ENDPOINT="<PUT_THE_ENDPOINT_HERE>"
   export BING_SEARCH_KEY="<PUT_THE_KEY_HERE>"
   ```

---

## 9. Configure OpenAI Environment Variables Locally

1. **Retrieve your OpenAI endpoint and key from Key Vault**  
   ```bash
   export AZURE_OPENAI_ENDPOINT=$(az keyvault secret show --vault-name kv-ai-news --name OpenAIEndpoint --query value -o tsv)
   export AZURE_OPENAI_KEY=$(az keyvault secret show --vault-name kv-ai-news --name OpenAIKey --query value -o tsv)
   ```

---

## 10. Use Sample Data for Local Testing

An example sample JSON response from Bing is provided in `sample_data/example_bing_response.json`. This file mimics the structure returned by the BingGroundedSearchTool.

To test locally:

1. Ensure `sample_data/example_bing_response.json` exists.
2. Enable sample mode:  
   ```bash
   export USE_SAMPLE=true
   ```
3. Run the agent:  
   ```bash
   python template.py
   ```  
4. Verify the Markdown table output in your console.

---

## 11. Verify and Monitor in Azure

1. In the Azure Portal, open your Function App (`aiNewsApp`).  
2. Under **Functions**, select the HTTP-triggered function (e.g., `Run`).  
3. Use **Test/Run** to invoke and check output.  
4. Enable **Application Insights** under **Monitoring** for logs and metrics.

---

## 12. (Optional) Schedule the Agent

To run automatically every 24 hours:

1. In your Function App, add a **Timer trigger**.  
2. Use a CRON expression:  
   - Hourly: `0 0 * * * *`  
   - Daily at midnight PT: `0 0 0 * * *`  
3. Deploy the updated code.

---

## 13. Cleanup

To remove all resources and avoid charges:

```bash
az group delete --name rg-ai-news --yes --no-wait
```

---

# Example Sample File

The example response is located at `sample_data/example_bing_response.json`.

