
# AI News Agent

This agent retrieves, prioritizes, and summarizes AI news developments with relevance to the Microsoft ecosystem, healthcare, and legal industries. It uses Bing News via SerpAPI to fetch high-credibility news sources and generates a Markdown-formatted summary table of up to 10 developments.

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

Refer to ['marquee_insights_logo.svg"]()./marquee_insights_logo.svg)

## 📜 License

This project is licensed under the MIT License.
