#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "ruby_llm"

GROQ_BASE_URL = "https://api.groq.com/openai/v1"
GROQ_MODEL_ID = ENV.fetch("LLM_MODEL", "llama-3.3-70b-versatile")

groq_key = ENV["GROQ_API_KEY"]

if groq_key.nil? || groq_key.empty?
  warn "ERROR: Please set GROQ_API_KEY in your environment."
  warn "Example: export GROQ_API_KEY='your-key-here'"
  exit 1
end

RubyLLM.configure do |config|
  # Treat Groq as an OpenAI-compatible provider
  config.openai_api_key  = groq_key
  config.openai_api_base = GROQ_BASE_URL

  # Do NOT set default_model to the Groq model,
  # that triggers registry validation.
end

# Create a chat bound to the Groq model, skipping registry lookup
chat = RubyLLM.chat(
  model: GROQ_MODEL_ID,
  provider: :openai,          # use OpenAI-style API format
  assume_model_exists: true   # <– important for Groq models
)

# Optional: system instructions
chat.with_instructions(
  "You are a concise, helpful assistant for a Ruby developer.",
  replace: true
)

def divider
  puts "-" * 60
end

puts "RubyLLM Console (Groq)"
puts "Model: #{GROQ_MODEL_ID}"
divider
puts "Type your message, or 'exit' / 'quit' to leave."
divider

loop do
  print "You> "
  input = STDIN.gets
  break if input.nil?

  input = input.strip
  break if input.match?(/\A(exit|quit)\z/i)
  next if input.empty?

  puts
  puts "Thinking..."
  puts

  begin
    response = chat.ask(input) # RubyLLM::Message
    divider
    puts "Assistant:"
    puts response.content
    divider
  rescue RubyLLM::RateLimitError => e
    divider
    puts "Assistant:"
    puts "Hit Groq rate limit or quota. Check your Groq dashboard."
    puts
    puts "(#{e.class}: #{e.message})"
    divider
  rescue RubyLLM::Error => e
    divider
    puts "API error: #{e.class} – #{e.message}"
    divider
  rescue StandardError => e
    divider
    puts "Unexpected error: #{e.class} – #{e.message}"
    divider
  end
end

puts
puts "Goodbye!"