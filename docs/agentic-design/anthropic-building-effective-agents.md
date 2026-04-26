# Building Effective AI Agents — Anthropic

**Source:** https://www.anthropic.com/engineering/building-effective-agents
**Authors:** Erik Schluntz and Barry Zhang
**Published:** December 19, 2024

---

## Introduction

"Over the past year, we've worked with dozens of teams building large language model (LLM) agents across industries." The most successful implementations shared a common trait: they relied on straightforward, composable design rather than elaborate frameworks.

This article synthesizes lessons learned from customer work and internal development to provide actionable guidance for developers creating effective agents.

## What Are Agents?

The term "agent" encompasses various definitions. Some organizations view agents as fully autonomous systems operating independently over extended periods using multiple tools. Others describe more structured implementations following predefined workflows.

Anthropic categorizes these as **agentic systems** but distinguishes two architectural categories:

- **Workflows**: Systems where LLMs and tools operate through predefined code paths
- **Agents**: Systems where LLMs autonomously direct their own processes and tool usage

Both patterns appear throughout production environments, each serving different purposes based on task requirements.

## When (and When Not) to Use Agents

The core principle: find the simplest adequate solution before adding complexity. Agentic systems typically exchange latency and cost for improved task performance — a tradeoff worth making only when justified.

Workflows excel for well-defined tasks requiring predictability and consistency. Agents suit scenarios demanding flexibility and model-driven decision-making at scale. Many applications benefit most from optimizing individual LLM calls with retrieval and contextual examples.

## When and How to Use Frameworks

Several frameworks simplify agentic system implementation:

- Claude Agent SDK
- Strands Agents SDK by AWS
- Rivet (drag-and-drop GUI for workflows)
- Vellum (GUI tool for complex workflows)

These tools reduce friction around standard tasks like API calls, tool definition, and request chaining. However, they introduce abstraction layers obscuring underlying prompts and responses, complicating debugging. They can also encourage unnecessary complexity.

**Recommendation**: Start by using LLM APIs directly, as many patterns require minimal code. If frameworks are adopted, thoroughly understand underlying mechanisms to avoid misconceptions about functionality.

## Building Blocks, Workflows, and Agents

### Building Block: The Augmented LLM

The foundation of agentic systems combines an LLM with augmentations including retrieval, tools, and memory. Current models actively leverage these capabilities — generating search queries, selecting tools, and determining information retention.

Implementation focus areas:

1. Tailor capabilities to specific use cases
2. Ensure accessible, well-documented interfaces for the LLM

The Model Context Protocol offers one approach, enabling integration with expanding third-party tool ecosystems through straightforward client implementations.

### Workflow: Prompt Chaining

This pattern decomposes tasks into sequential steps where each LLM call processes previous output. Programmatic checks ("gates") at intermediate steps maintain process validity.

**When to use**: Tasks decomposing cleanly into fixed subtasks, trading latency for accuracy by simplifying individual LLM calls.

**Examples**:
- Marketing copy generation followed by translation
- Document outline creation with validation, then full document writing

### Workflow: Routing

Routing classifies inputs and directs them to specialized followup tasks, enabling separation of concerns and prompt specialization. Input-specific optimization avoids performance degradation on other input types.

**When to use**: Complex tasks with distinct categories handled separately, where accurate classification is achievable.

**Examples**:
- Customer service query categorization (general questions, refunds, technical support)
- Routing to appropriately-sized models based on query difficulty

### Workflow: Parallelization

LLMs can work simultaneously on tasks with aggregated outputs. Two key variations:

- **Sectioning**: Breaking tasks into independent parallel subtasks
- **Voting**: Running identical tasks multiple times for diverse outputs

For complex multi-faceted problems, separate LLM calls focused on individual aspects typically outperform unified approaches.

**Sectioning examples**:
- Parallel guardrails (one instance handles queries, another screens for inappropriate content)
- Automated evaluation where different instances assess different performance aspects

**Voting examples**:
- Code review for vulnerabilities across multiple prompt variations
- Content inappropriateness evaluation with threshold requirements

### Workflow: Orchestrator-Workers

A central LLM dynamically breaks down tasks, delegates to worker LLMs, and synthesizes results.

**When to use**: Complex tasks with unpredictable subtask requirements. Unlike parallelization, subtasks aren't pre-defined but determined based on specific input.

**Examples**:
- Code modifications affecting multiple unpredictable files
- Information gathering and analysis from multiple sources

### Workflow: Evaluator-Optimizer

One LLM generates responses while another provides evaluation and feedback in loops.

**When to use**: Clear evaluation criteria exist and iterative refinement measurably improves results. Signs of suitability include responses improving with human feedback and the LLM providing such feedback.

**Examples**:
- Literary translation capturing nuanced language
- Complex search requiring multiple rounds of analysis

### Agents

Agents operate independently following human instruction or collaborative discussion. They plan autonomously, integrating environmental feedback ("ground truth") at each step — tool results, code execution outcomes. They pause for human feedback at checkpoints or when blocked.

Agent implementation, despite apparent sophistication, typically involves straightforward code: LLMs using tools based on environmental feedback in loops. Careful toolset design and documentation prove critical.

**When to use**: Open-ended problems where step counts cannot be predicted and fixed paths cannot be hardcoded. This requires trust in model decision-making and suits scaling in trusted environments.

**Characteristics**: Higher costs and potential for compounding errors demand extensive sandboxed testing and appropriate guardrails.

**Anthropic examples**:
- SWE-bench task resolution (multiple file editing)
- Computer use reference implementation

## Combining and Customizing Patterns

These patterns remain non-prescriptive. Developers should shape and combine them for specific use cases, prioritizing performance measurement and iterative refinement. "Add complexity only when it demonstrably improves outcomes."

## Summary Principles

Success requires building the *right* system, not the most sophisticated one. Begin with simple prompts, optimize through comprehensive evaluation, and introduce multi-step systems only when simpler approaches plateau.

Three core implementation principles:

1. **Simplicity** in agent design
2. **Transparency** through explicit planning step visibility
3. **Documentation and testing** for agent-computer interfaces (ACI), with effort matching human-computer interface design investment

Frameworks accelerate startup but shouldn't prevent reducing abstraction and building with fundamental components for production systems.

## Appendix 1: Agents in Practice

Two applications show particular promise:

### Customer Support

Support naturally combines conversational interfaces with tool-enabled capabilities:

- Conversations naturally flow while requiring external information/actions
- Tools access customer data, order history, knowledge bases
- Programmatic actions (refunds, ticket updates)
- Clear success measurement via user-defined resolutions

Usage-based pricing (charging only for successful resolutions) demonstrates organizational confidence in agent effectiveness.

### Coding Agents

Software development demonstrates strong LLM potential:

- Code solutions are automatically verifiable
- Agents iterate using test feedback
- Well-defined, structured problem spaces
- Objectively measurable output quality

Anthropic agents now solve real GitHub issues in SWE-bench Verified benchmarks from pull requests alone, though human review remains essential for broader system alignment.

## Appendix 2: Prompt Engineering Tools

Tools enable Claude to interact with external services through specified structures. Careful attention to tool specification — matching prompt engineering effort — proves essential.

Multiple approaches exist for identical actions (diffs versus complete rewrites, markdown versus JSON code). Some formats present greater LLM difficulty. Writing diffs requires predicting line counts; JSON code requires quote/newline escaping.

**Tool format recommendations**:

- Allocate sufficient tokens for model reasoning before commitment to specific directions
- Keep formats aligned with naturally occurring internet text
- Eliminate formatting overhead (line counting, string escaping)

**Agent-Computer Interface design parallels human-computer interface effort**:

- Evaluate clarity: Is tool usage obvious from descriptions and parameters?
- Optimize parameter names and descriptions for clarity
- Test extensively with example inputs, iterating on observed mistakes
- Apply "poka-yoke" principles, adjusting arguments to prevent errors

Anthropic's SWE-bench agent involved greater tool optimization than overall prompt engineering. Requiring absolute instead of relative filepaths eliminated post-directory-change errors.
