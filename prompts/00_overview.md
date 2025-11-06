# Agent Checkpoints Framework - Overview for AI Agents

## What is ACF?

The Agent Checkpoints Framework (ACF) is a coordination system for managing work done by humans and AI agents over extended timelines.

## Core Concept

**CHECKPOINT** = A structured directory containing:
- Work artifacts
- Status tracking
- Verification results
- Dependency contracts
- Audit trail

## Key Principle

Design the back-pressure harness before implementation. The framework ensures agents know "how will I know I'm working correctly?" at every stage.

## Navigation

When you need details:
- Workflow stages → See FRAMEWORK_SPEC.md
- Failure modes → See FAILURE_CATALOGUE_TABLE.md
- CLI commands → See CLI_REFERENCE.md
- Design rationale → See FRAMEWORK_FOUNDATION.md

## Primary Workflow

PREPARE → SPECIFY → BUILD → VERIFY → HANDOFF

Each stage has explicit exit criteria and verification steps.
