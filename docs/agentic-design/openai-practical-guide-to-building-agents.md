# A Practical Guide to Building Agents — OpenAI

**Source:** https://openai.com/business/guides-and-resources/a-practical-guide-to-building-ai-agents/
**PDF:** https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf
**Published:** 2025

---

## Introduction

Large language models are becoming increasingly capable of handling complex, multi-step tasks. Advances in reasoning, multimodality, and tool use have unlocked a new category of LLM-powered systems known as agents.

This guide is designed for product and engineering teams exploring how to build their first agents, distilling insights from numerous customer deployments into practical and actionable best practices. It includes frameworks for identifying promising use cases, clear patterns for designing agent logic and orchestration, and best practices to ensure your agents run safely, predictably, and effectively.

## What is an Agent?

While conventional software enables users to streamline and automate workflows, agents are able to perform the same workflows on the users' behalf with a high degree of independence.

**Agents are systems that independently accomplish tasks on your behalf.**

A workflow is a sequence of steps that must be executed to meet the user's goal, whether that's resolving a customer service issue, booking a restaurant reservation, committing a code change, or generating a report.

Applications that integrate LLMs but don't use them to control workflow execution — think simple chatbots, single-turn LLMs, or sentiment classifiers — are not agents.

More concretely, an agent possesses core characteristics:

1. It leverages an LLM to manage workflow execution and make decisions. It recognizes when a workflow is complete and can proactively correct its actions if needed. In case of failure, it can halt execution and transfer control back to the user.

2. It has access to various tools to interact with external systems — both to gather context and to take actions — and dynamically selects the appropriate tools depending on the workflow's current state, always operating within clearly defined guardrails.

## When Should You Build an Agent?

Building agents requires rethinking how your systems make decisions and handle complexity. Unlike conventional automation, agents are uniquely suited to workflows where traditional deterministic and rule-based approaches fall short.

Consider the example of payment fraud analysis. A traditional rules engine works like a checklist, flagging transactions based on preset criteria. In contrast, an LLM agent functions more like a seasoned investigator, evaluating context, considering subtle patterns, and identifying suspicious activity even when clear-cut rules aren't violated.

Prioritize workflows that have previously resisted automation, especially where traditional methods encounter friction:

1. **Complex decision-making**: Workflows involving nuanced judgment, exceptions, or context-sensitive decisions (e.g. refund approval in customer service workflows)

2. **Difficult-to-maintain rules**: Systems that have become unwieldy due to extensive and intricate rulesets, making updates costly or error-prone (e.g. performing vendor security reviews)

3. **Heavy reliance on unstructured data**: Scenarios that involve interpreting natural language, extracting meaning from documents, or interacting with users conversationally (e.g. processing a home insurance claim)

Before committing to building an agent, validate that your use case can meet these criteria clearly. Otherwise, a deterministic solution may suffice.

## Agent Design Foundations

In its most fundamental form, an agent consists of three core components:

1. **Model**: The LLM powering the agent's reasoning and decision-making
2. **Tools**: External functions or APIs the agent can use to take action
3. **Instructions**: Explicit guidelines and guardrails defining how the agent behaves

### Selecting Your Models

Different models have different strengths and tradeoffs related to task complexity, latency, and cost. You might want to consider using a variety of models for different tasks in the workflow.

Not every task requires the smartest model — a simple retrieval or intent classification task may be handled by a smaller, faster model, while harder tasks like deciding whether to approve a refund may benefit from a more capable model.

An approach that works well is to build your agent prototype with the most capable model for every task to establish a performance baseline. From there, try swapping in smaller models to see if they still achieve acceptable results.

Principles for choosing a model:
1. Set up evals to establish a performance baseline
2. Focus on meeting your accuracy target with the best models available
3. Optimize for cost and latency by replacing larger models with smaller ones where possible

### Defining Tools

Tools extend your agent's capabilities by using APIs from underlying applications or systems. Each tool should have a standardized definition, enabling flexible, many-to-many relationships between tools and agents. Well-documented, thoroughly tested, and reusable tools improve discoverability, simplify version management, and prevent redundant definitions.

Broadly speaking, agents need three types of tools:

| Type | Description | Examples |
|------|-------------|----------|
| Data | Enable agents to retrieve context and information necessary for executing the workflow | Query transaction databases or systems like CRMs, read PDF documents, or search the web |
| Action | Enable agents to interact with systems to take actions such as adding new information to databases, updating records, or sending messages | Send emails and texts, update a CRM record, hand-off a customer service ticket to a human |
| Orchestration | Agents themselves can serve as tools for other agents | Refund agent, Research agent, Writing agent |

As the number of required tools increases, consider splitting tasks across multiple agents (see Orchestration).

### Configuring Instructions

High-quality instructions are essential for any LLM-powered app, but especially critical for agents. Clear instructions reduce ambiguity and improve agent decision-making, resulting in smoother workflow execution and fewer errors.

Best practices for agent instructions:

- **Use existing documents**: When creating routines, use existing operating procedures, support scripts, or policy documents to create LLM-friendly routines.
- **Prompt agents to break down tasks**: Providing smaller, clearer steps from dense resources helps minimize ambiguity and helps the model better follow instructions.
- **Define clear actions**: Make sure every step in your routine corresponds to a specific action or output. Being explicit about the action leaves less room for errors in interpretation.
- **Capture edge cases**: Real-world interactions often create decision points. A robust routine anticipates common variations and includes instructions on how to handle them with conditional steps or branches.

## Orchestration

With the foundational components in place, you can consider orchestration patterns to enable your agent to execute workflows effectively.

While it's tempting to immediately build a fully autonomous agent with complex architecture, customers typically achieve greater success with an incremental approach.

Orchestration patterns fall into two categories:

1. **Single-agent systems**: A single model equipped with appropriate tools and instructions executes workflows in a loop
2. **Multi-agent systems**: Workflow execution is distributed across multiple coordinated agents

### Single-Agent Systems

A single agent can handle many tasks by incrementally adding tools, keeping complexity manageable and simplifying evaluation and maintenance. Each new tool expands its capabilities without prematurely forcing you to orchestrate multiple agents.

Every orchestration approach needs the concept of a "run", typically implemented as a loop that lets agents operate until an exit condition is reached. Common exit conditions include tool calls, a certain structured output, errors, or reaching a maximum number of turns.

An effective strategy for managing complexity without switching to a multi-agent framework is to use **prompt templates**. Rather than maintaining numerous individual prompts for distinct use cases, use a single flexible base prompt that accepts policy variables. This template approach adapts easily to various contexts, significantly simplifying maintenance and evaluation.

### When to Consider Multiple Agents

General recommendation: maximize a single agent's capabilities first. More agents can provide intuitive separation of concepts, but can introduce additional complexity and overhead.

Practical guidelines for splitting agents:

- **Complex logic**: When prompts contain many conditional statements (multiple if-then-else branches), and prompt templates get difficult to scale, consider dividing each logical segment across separate agents.
- **Tool overload**: The issue isn't solely the number of tools, but their similarity or overlap. Some implementations successfully manage more than 15 well-defined, distinct tools while others struggle with fewer than 10 overlapping tools.

### Multi-Agent Systems

Two broadly applicable categories:

**Manager pattern (agents as tools)**: A central "manager" agent coordinates multiple specialized agents via tool calls, each handling a specific task or domain. Ideal for workflows where you only want one agent to control workflow execution and have access to the user.

**Decentralized pattern (agents handing off to agents)**: Multiple agents operate as peers, handing off tasks to one another based on their specializations. Effective for scenarios like conversation triage, or when specialized agents should fully take over certain tasks.

Regardless of the orchestration pattern, the same principles apply: keep components flexible, composable, and driven by clear, well-structured prompts.

## Guardrails

Well-designed guardrails help you manage data privacy risks (e.g. preventing system prompt leaks) or reputational risks (e.g. enforcing brand-aligned model behavior). Guardrails are a critical component of any LLM-based deployment, but should be coupled with robust authentication and authorization protocols, strict access controls, and standard software security measures.

Think of guardrails as a layered defense mechanism. While a single one is unlikely to provide sufficient protection, using multiple, specialized guardrails together creates more resilient agents.

### Types of Guardrails

- **Relevance classifier**: Ensures agent responses stay within intended scope by flagging off-topic queries
- **Safety classifier**: Detects unsafe inputs (jailbreaks or prompt injections) that attempt to exploit system vulnerabilities
- **PII filter**: Prevents unnecessary exposure of personally identifiable information by vetting model output
- **Moderation**: Flags harmful or inappropriate inputs (hate speech, harassment, violence)
- **Tool safeguards**: Assess the risk of each tool by assigning a rating — low, medium, or high — based on factors like read-only vs. write access, reversibility, required permissions, and financial impact. Use these risk ratings to trigger automated actions, such as pausing for guardrail checks before executing high-risk functions or escalating to a human if needed.
- **Rules-based protections**: Simple deterministic measures (blocklists, input length limits, regex filters) to prevent known threats
- **Output validation**: Ensures responses align with brand values via prompt engineering and content checks

### Building Guardrails

Heuristic for building guardrails:
1. Focus on data privacy and content safety
2. Add new guardrails based on real-world edge cases and failures you encounter
3. Optimize for both security and user experience, tweaking guardrails as your agent evolves

### Plan for Human Intervention

Human intervention is a critical safeguard enabling you to improve an agent's real-world performance without compromising user experience. It's especially important early in deployment, helping identify failures, uncover edge cases, and establish a robust evaluation cycle.

Two primary triggers for human intervention:

- **Exceeding failure thresholds**: Set limits on agent retries or actions. If the agent exceeds these limits (e.g. fails to understand customer intent after multiple attempts), escalate to human intervention.
- **High-risk actions**: Actions that are sensitive, irreversible, or have high stakes should trigger human oversight until confidence in the agent's reliability grows. Examples include canceling user orders, authorizing large refunds, or making payments.

## Conclusion

Agents mark a new era in workflow automation, where systems can reason through ambiguity, take action across tools, and handle multi-step tasks with a high degree of autonomy.

To build reliable agents, start with strong foundations: pair capable models with well-defined tools and clear, structured instructions. Use orchestration patterns that match your complexity level, starting with a single agent and evolving to multi-agent systems only when needed. Guardrails are critical at every stage.

The path to successful deployment isn't all-or-nothing. Start small, validate with real users, and grow capabilities over time. With the right foundations and an iterative approach, agents can deliver real business value — automating not just tasks, but entire workflows with intelligence and adaptability.
