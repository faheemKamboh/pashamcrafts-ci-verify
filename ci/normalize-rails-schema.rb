# frozen_string_literal: true

unless ARGV.length == 4
  warn "usage: normalize-rails-schema.rb COMMITTED GENERATED COMMITTED_OUTPUT GENERATED_OUTPUT"
  exit 64
end

def normalize_schema(content)
  content.lines.map do |line|
    next line unless line.include?("t.check_constraint")

    line
      .gsub(/'([^']*)'::character varying(?:::text)?/, "'\\1'")
      .gsub(/\]::text\[\]/, "]")
  end.join
end

committed_path, generated_path, committed_output, generated_output = ARGV
File.write(committed_output, normalize_schema(File.read(committed_path)))
File.write(generated_output, normalize_schema(File.read(generated_path)))
