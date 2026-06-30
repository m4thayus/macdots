# frozen_string_literal: true

# Shared identity helpers for the github tools: who Matt is (commit emails,
# handle) and how to resolve a --user value to a GitHub handle.
mixin 'identity' do
  # First-name → GitHub handle; unlisted values (a real handle, "@me") pass
  # through verbatim. Handles verified against gh api users/<handle>.
  def resolve_handle(who)
    {
      'matt' => 'm4thayus',
      'scott' => 'scottb',
      'james' => 'JlordA',
      'amit' => 'AmitP1585',
      'elizabeth' => 'ElizabethKaren',
      'zoe' => 'zoeblairfriedman',
      'bianca' => 'Bcharlotin1',
      'peter' => 'PeterViss'
    }[who.downcase] || who
  end

  # Matt's commit-author emails. The noreply address is what GitHub stamps on
  # web-UI commits (Revert button, squash merges, web edits, suggestions), so
  # those count as his too. The numeric id (48694013) is the permanent GitHub
  # account id — it never changes. (Legacy pre-2017 form would be
  # m4thayus@users.noreply.github.com; add it only if an old commit needs it.)
  def my_emails
    %w[
      mattw@mercuryanalytics.com
      matt.seongjun@gmail.com
      48694013+m4thayus@users.noreply.github.com
    ]
  end

  # Matt's own GitHub handle (single source of truth via the map above).
  def me_handle = resolve_handle('matt')
end
