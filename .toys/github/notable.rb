# frozen_string_literal: true

desc "Show notable PRs"
flag :team

def run
  require "date"
  require "uri"
  require "cgi"

  today = Date.today
  wday = today.wday
  last_meeting = today - wday - 6
  last_meeting += 1 if team

  options = [
    "org:mercuryanalytics",
    "is:pr",
    "-is:draft",
    "-label:dependencies",
    "-label:reverted"
  ]

  options << (team ? "author:@me" : "label:notable")

  options << "closed:>=#{last_meeting}"

  template = '{{range .}}{{printf "#%-5v %-7s %s\n" .number .state .title}}{{end}}'
  system("gh", "search", "prs",
         "--json", "number,state,title",
         "--template", template,
         "--", *options)

  u = URI("https://github.com/search")
  u.query = { type: "pullrequests", q: options.join(" ") }
            .transform_values! { |v| CGI.escape(v) }
            .map { |k, v| "#{k}=#{v}" }
            .join("&")
  puts "\e]8;;#{u}\e\\[link]\e]8;;\e\\"
end
