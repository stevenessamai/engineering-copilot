# Example: AI/RAG Improvement

**User request:**
> `/engineering-copilot:plan "our support-bot RAG answers are citing the wrong document sections — improve retrieval quality"`

**Plugin workflow:**
1. `/plan` detects the AI stack during discovery: an embeddings call, a vector store, and a chunking step feeding a prompt template.
2. Inspects the chunking strategy and finds fixed-size character chunking with no overlap and no respect for document structure (headers, sections) — a likely cause of retrieval mismatch.
3. Inspects the retrieval step: top-k is fixed at 3 with no reranking.
4. Produces a plan covering the AI-specific impact areas required by Engineering Copilot: model impact (none), prompt impact (citation format needs the chunk's source section, not just document name), tool impact (none), context impact (larger, structure-aware chunks with overlap), evaluation impact (needs a small labeled eval set to measure retrieval precision before/after), cost impact (re-embedding the corpus is a one-time cost), latency impact (reranking adds a bounded step, quantified).

**Expected output (excerpt):**
```
## AI changes
Model impact: none — embedding model unchanged
Prompt impact: system prompt updated to require citing chunk-level
  section headers, not just document titles
Context impact: chunking moves from fixed 500-char blocks to
  structure-aware chunking (split on headers, 15% overlap)
Evaluation impact: add a 25-question labeled eval set; measure
  retrieval precision@3 before and after this change
Cost impact: one-time re-embedding of ~40k chunks
Latency impact: optional reranking step adds ~80-150ms per query;
  flagged as an explicit tradeoff, not silently added

## Testing plan
- Eval set run before/after chunking change, precision@3 reported
- Unit tests for the new chunker's boundary handling
```
