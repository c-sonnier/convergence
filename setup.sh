#!/bin/bash
set -e

# Convergence — Setup Script
# Installs skills and agents for Claude Code

CONVERGENCE_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"

echo "Convergence — Installing skills and agents"
echo "============================================"
echo ""

# Create directories
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

# Install skills
SKILLS=(research design outline implement review debug tdd security architecture)

for skill in "${SKILLS[@]}"; do
  target="$SKILLS_DIR/convergence-${skill}"
  if [ -L "$target" ] || [ -d "$target" ]; then
    echo "  [update] convergence-${skill}"
    rm -rf "$target"
  else
    echo "  [install] convergence-${skill}"
  fi
  ln -s "$CONVERGENCE_DIR/skills/${skill}" "$target"
done

echo ""

# Install agents
AGENTS=(research-agent review-agent security-agent)

for agent in "${AGENTS[@]}"; do
  target="$AGENTS_DIR/convergence-${agent}.md"
  if [ -L "$target" ] || [ -f "$target" ]; then
    echo "  [update] convergence-${agent}"
    rm -f "$target"
  else
    echo "  [install] convergence-${agent}"
  fi
  ln -s "$CONVERGENCE_DIR/.claude/agents/${agent}.md" "$target"
done

echo ""
echo "Installed ${#SKILLS[@]} skills and ${#AGENTS[@]} agents."
echo ""
echo "Skills available:"
for skill in "${SKILLS[@]}"; do
  echo "  /convergence-${skill}"
done
echo ""
echo "To install into a specific project instead of globally:"
echo "  cd your-project"
echo "  mkdir -p .claude/skills"
echo "  ln -s $CONVERGENCE_DIR/skills/* .claude/skills/"
echo ""
echo "Done."
