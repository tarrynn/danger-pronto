module Danger
  # Lints files via Pronto through specified runners
  # Results are displayed as a table in markdown
  #
  # [Runners](https://github.com/mmozuras/pronto#runners)
  #
  # @example Lint files with Pronto and specified Pronto Runners
  #
  #          pronto.lint
  #
  # @see  RestlessThinker/danger-pronto
  # @tags pronto, linter
  #
  class DangerPronto < Plugin

    # Runs files through Pronto. Generates a `markdown` list of warnings.
    def lint(commit = nil)
      files = pronto(commit)
      return if files.empty?
      markdown offenses_message(files)
    end

    private

    # Executes pronto command
    # @param commit [String] hash/branch/tag
    # @return [Hash] Converted hash from pronto json output
    def pronto(specified_commit = nil)
      commit = "origin/staging"
      commit = specified_commit if !specified_commit.nil?
      pronto_output = `#{'bundle exec ' if File.exists?('Gemfile')}pronto run -f json -c #{commit}`

      # regex to grab substring between 1st '[' and last ']' due to the fact pronto has other output alongside the json
      # we add these chars back into the string
      JSON.parse("[#{pronto_output.slice(/\[(.*)\]/,1)}]")
    end

    # Builds the message
    def offenses_message(offending_files)
      require 'terminal-table'

      message = "### Pronto violations\n\n"
      table = Terminal::Table.new(
        headings: %w(File Line Reason Runner),
        style: { border_i: '|' },
        rows: offending_files.map do |file|
          [file['path'], file['line'], file['message'], file['runner']]
        end
      ).to_s
      message + table.split("\n")[1..-2].join("\n")
    end
  end
end
