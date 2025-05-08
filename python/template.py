import os
from dotenv import load_dotenv
from azure.identity import DefaultAzureCredential
from azure.ai.agents import AgentsClient
from azure.ai.agents.models import BingGroundingTool

# Load environment variables from .env file
load_dotenv()

# Configuration from environment
PROJECT_ENDPOINT = os.getenv("PROJECT_ENDPOINT")
MODEL_DEPLOYMENT_NAME = os.getenv("MODEL_DEPLOYMENT_NAME")
BING_CONNECTION_ID = os.getenv("BING_CONNECTION_ID")

# Validate configuration
if not all([PROJECT_ENDPOINT, MODEL_DEPLOYMENT_NAME, BING_CONNECTION_ID]):
    raise ValueError("Missing one or more environment variables: PROJECT_ENDPOINT, MODEL_DEPLOYMENT_NAME, BING_CONNECTION_ID")

# Initialize the Agents client
agents_client = AgentsClient(
    endpoint=PROJECT_ENDPOINT,
    credential=DefaultAzureCredential(),
)

# Load system prompt instructions
with open("system_prompt.txt", "r", encoding="utf-8") as f:
    instructions = f.read().strip()

# Initialize the Bing Grounding tool
bing_tool = BingGroundingTool(connection_id=BING_CONNECTION_ID)

# Create or update the AI News agent
with agents_client:
    agent = agents_client.create_agent(
        model=MODEL_DEPLOYMENT_NAME,
        name="ai-news",
        instructions=instructions,
        tools=bing_tool.definitions,
    )

print(f"AI News agent created with ID: {agent.id}")
