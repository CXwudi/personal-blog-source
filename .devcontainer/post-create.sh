git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate

# --- AI CLIs -----------------------------------------------------------
# Install AI CLIs globally via npm
npm install -g \
  @anthropic-ai/claude-code \
  @google/gemini-cli \
  @openai/codex

# Optional: verify installation (uncomment if you want logs during build)
# claude --version || true
# gemini --version || true
# codex --version || true
