import os
import datetime
from dateutil import tz
from azure.ai.projects import AIClient  # Azure AI Projects SDK
from azure.ai.projects.models import ToolConfiguration, AgentOptions
from azure.ai.projects.tools import BingGroundedSearchTool
from azure.core.credentials import AzureKeyCredential
from azure.ai.projects.prompts import SystemMessagePromptTemplate 

# Configuration
TIME_LOOKBACK_HOURS = int(os.getenv("TIME_LOOKBACK_HOURS", "24"))
MAX_ITEMS = int(os.getenv("MAX_ITEMS", "10"))
PRIORITY_ORDER = [
    "Microsoft+Healthcare",
    "Microsoft+Legal",
    "Healthcare",
    "Legal",
]
CREDIBLE_SOURCES = ["gartner.com", "reuters.com", "wired.com", "mit.edu", "stanford.edu", "berkeley.edu", "washington.edu", "ox.ac.uk", "cam.ac.uk", "ethz.ch", "mpg.de", "csail.mit.edu", "isi.edu", "deepmind.com", "openai.com", "research.google", "ai.facebook.com", "microsoft.com/en-us/research", "nvidia.com/research", "ieee.org", "ieeexplore.ieee.org", "jair.org", "neuralnetworksjournal.com", "sciencedaily.com", "technologyreview.com", "wired.com", "theverge.com", "techcrunch.com", "analyticsinsight.net", "aimagazine.com", "aitrends.com", "aichief.com", "techtarget.com"]

# Initialize client and tools
auth = AzureKeyCredential(os.getenv("AZURE_OPENAI_KEY"))
client = AIClient(
    endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    credential=auth
)

bing_tool = BingGroundedSearchTool(
    name="bing",
    credential=os.getenv("BING_SEARCH_KEY")
)

# Load system prompt
with open("system_prompt.txt", "r", encoding="utf-8") as f:
    system_prompt_text = f.read()
system_prompt = SystemMessagePromptTemplate.from_template(system_prompt_text)

# Create agent with system prompt
agent = client.create_agent(
    name="ai-news",
    tools=[ToolConfiguration(alias="bing", tool=bing_tool)],
    options=AgentOptions(default_model="gpt-4o-mini"),
    system_message=system_prompt
)

agent = client.create_agent(
    name="ai-developments-aggregation-agent",
    tools=[ToolConfiguration(alias="bing", tool=bing_tool)],
    options=AgentOptions(
        default_model="gpt-4o-mini"
    )
)

# Compute time window (Pacific)
tz_pacific = tz.gettz("America/Los_Angeles")
end_time = datetime.datetime.now(tz_pacific)
start_time = end_time - datetime.timedelta(hours=TIME_LOOKBACK_HOURS)

def build_query():
    return f"AI development news after {start_time.isoformat()} before {end_time.isoformat()}"

# Run the agent workflow
def main():
    query = build_query()
    response = agent.invoke(
        user_message=query
    )

    # Agent prompt should handle filtering, prioritization, summarization, and formatting
    print(response.content)

if __name__ == "__main__":
    main()