
# AI News Agent

AI News is an intelligent information summarization agent designed to help executives and decision-makers stay on top of the rapidly evolving world of artificial intelligence. By continuously scanning credible news sources, it identifies and summarizes the most impactful AI developments—especially those relevant to the Microsoft ecosystem, healthcare, and construction industries.

The agent reduces information overload by prioritizing high-value updates and presenting them in a clear, digestible Markdown table format. Each summary includes a headline, date, key insight, strategic implications, and a verified source link.
AI News is not a replacement for human analysis or legal due diligence. Instead, it augments executive awareness by surfacing credible developments that may require further attention or discussion. All strategic decisions and compliance assessments remain the responsibility of the end user.


## 🔍 What It Does

- Searches Bing News for the latest AI developments (last 24 hours)
- Prioritizes based on impact and source credibility
- Summarizes news and implications for Microsoft, Healthcare, and Legal sectors
- Returns results as a Markdown table

## 🧠 Agent Instructions

The agent follows a system prompt that enforces:
- Source filtering (e.g., MIT, Gartner, Reuters)
- Market focus (Microsoft > Healthcare > Legal)
- Clear formatting: Markdown table with headlines, dates, summaries, implications, and links

## 🛠 Tools

### AskSerpAPI (OpenAPI Tool)
- **Description**: Searches recent AI-related news using Bing News via SerpAPI
- **Auth**: Azure-managed connection to SerpAPI (no user-side auth setup)
- **Reference**: OpenAPI schema is included in the repo

## 🧪 Sample Prompts

- "What are the most impactful AI developments for Microsoft in the last 24 hours?"
- "Summarize recent legal sector AI news."
- "Healthcare-related AI breakthroughs today?"

## 📁 Example Notebook

Refer to [`agent-ai-news.ipynb`](./agent-ai-news.ipynb) for step-by-step usage.

## 🖼 Logo

Refer to ['marquee_insights_logo.svg"](./marquee_insights_logo.svg)

## 📜 License

This project is licensed under the MIT License.
