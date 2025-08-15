# frozen_string_literal: true

desc 'Run a synthetic conversation'

include :bundler

optional_arg :question, accept: String, default: '1760/1760_mercuryiq_test', desc: 'Workbench question name (project/question)'
optional_arg :count, accept: Integer, default: 1, desc: 'Count of conversations per persona'
at_least_one_required desc: 'Personas (at least one required)' do
  flag :bot, '-b', '--bot'
  flag :compliant, '-c', '--compliant'
  flag :needs_coaxing, '-x', '--needs-coaxing'
  flag :non_compliant, '-n', '--non-compliant'
  flag :terse, '-t', '--terse'
end
flag :config, '--config [FILE]', complete_values: :file_system, desc: 'The YML configuration file with metadata for the conversation'

def run
  personas = []
  personas << 'bot' unless bot.nil?
  personas << 'compliant' unless compliant.nil?
  personas << 'needs_coaxing' unless needs_coaxing.nil?
  personas << 'non_compliant' unless non_compliant.nil?
  personas << 'terse' unless terse.nil?

  task = "rails thoth:conversation:generate['#{options[:question]}','#{personas.join('|')}',#{options[:count]}]"
  if config.nil?
    exec task
  else
    exec "CONFIG=#{config} #{task}"
  end
end
