# Issue: Undocumented `_inputs/` folder pattern

## Observed Usage

Found in production work cells.

**Pattern**: `_inputs/` directory contains source materials that the work cell processes, analyzes, or transforms:
- Meeting transcripts
- Stakeholder communications
- Personal notes and annotations
- Reference documents and templates
- Scripts/tools for analysis
- Historical context materials

**Usage in CELL.md**: Heavily referenced throughout all sections:
- `./_inputs/meeting_transcript.md` - cited as source for requirements
- `./_inputs/stakeholder_chat.md` - stakeholder guidance
- `./_inputs/assets/analysis_template.md` - reference template
- Typical usage: ~15-20 references per CELL.md, appearing in FULL_RATIONALE, FULL_IMPLEMENTATION, and LOG sections

## Philosophy

**`_inputs/` is the semantic complement to `_outputs/`**:
- `_outputs/` = deliverables FOR consumption BY others (other cells, humans, external systems)
- `_inputs/` = materials FOR consumption BY this work cell FROM stakeholders/external sources

**Value proposition**:
1. **Clear provenance**: Distinguishes "what I'm working from" vs "what I'm producing"
2. **Traceability**: All source materials in one place, easily referenced with `./_inputs/filename.md`
3. **Reproducibility**: Future readers can access the same context that informed decisions
4. **Boundary clarity**: Input materials are read-only references, not working files (those go in root)

**Observed file organization pattern**:
```
work_cell_v1_01/
├── CELL.md
├── _inputs/           # Source materials FROM external sources
│   ├── 01_meeting_transcript.md
│   ├── 02_stakeholder_email.md
│   └── assets/        # Supporting tools/templates
├── _outputs/          # Deliverables FOR other consumers
│   ├── analysis.csv
│   └── model.pkl
├── working_notebook.ipynb  # Working files (cell root)
└── scratch.py              # Working files (cell root)
```

## Recommendation

**Incorporate into framework as documented convention**, not mandatory requirement.

**Rationale**:
- Natural complement to existing `_outputs/` convention
- Solves real organizational problem (distinguishing inputs from outputs from working files)
- Already demonstrates value in production usage (extensive CELL.md referencing)
- Consistent with framework's "explicit is better than implicit" philosophy
- Low overhead: optional pattern, only create when needed (like `_outputs/`)

**Proposed framework addition**:

Add to "File Organization" section in `02_work_cell_structure.md`:

```markdown
## File Organization

File organization within work cell:

- **`_outputs/`** - Deliverables for consumption by other cells, humans, or external systems (modules, datasets, reports, APIs, compiled artifacts)
- **`_inputs/`** - (Optional) Source materials from stakeholders, meetings, or external sources that inform this work cell's activities (meeting transcripts, requirements documents, reference materials, stakeholder communications)
- **Root directory** - Working files (notebooks, debug scripts, scratch code)

Only files intended for consumption outside the cell belong in `_outputs/`.
Only files providing context from outside the cell belong in `_inputs/`.
```

**AI agent guidance**: Agents should understand this pattern exists but shouldn't be required to create `_inputs/` folders. Humans typically populate these with context materials before or during work. Agents should reference files in `_inputs/` when they exist (e.g., "per meeting transcript in `./_inputs/meeting.md`").
