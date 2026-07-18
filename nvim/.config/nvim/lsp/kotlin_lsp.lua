-- JetBrains official kotlin-lsp (IntelliJ-based, currently Alpha).
-- See: https://github.com/Kotlin/kotlin-lsp

return {
  cmd = { 'kotlin-lsp', '--stdio' },

  -- Include Java so mixed Kotlin/Java workspaces get cross-language updates.
  filetypes = { 'kotlin', 'java' },

  -- Heavy server: only attach when a real build root is present.
  single_file_support = false,

  root_markers = {
    'settings.gradle', -- Gradle multi-project
    'settings.gradle.kts',
    'pom.xml', -- Maven
    'build.gradle',
    'build.gradle.kts',
    'workspace.json', -- custom build integration
    -- Intentionally omit bare ".git" so monorepos don't start the server at the wrong root.
  },

  settings = {
    -- VS Code property names nest under jetbrains / intellij.
    jetbrains = {
      kotlin = {
        hints = {
          -- Core type / parameter hints (aligns with IntelliJ defaults).
          settings = {
            types = {
              property = true,
              variable = true,
            },
            lambda = {
              ['return'] = true,
            },
            value = {
              ranges = true,
            },
          },
          type = {
            ['function'] = {
              ['return'] = true,
              parameter = true,
            },
          },
          lambda = {
            receivers = {
              parameters = true,
            },
          },
          parameters = true,
          -- Noisy on long builders/Fluent APIs; opt in later if desired.
          call = {
            chains = false,
          },
        },
      },
    },
    -- Leave buildTool unset so Gradle/Maven autodetection wins.
    -- intellij = { buildTool = 'gradle' },
  },
}
