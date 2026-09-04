# frozen_string_literal: true

# Synthetic encoding fixtures. The sentences exist only to give rchardet enough
# English to score, and every high byte is hand-picked to probe one decision in
# TextEncoding.
#
# Bytes are written as escapes rather than as committed binary files, because a
# binary fixture is one careless editor save away from being silently re-encoded
# into the very thing it is supposed to detect.
module Fixtures
  # CP1252   0x85 …   0x91 ‘   0x92 ’   0x93 “   0x94 ”
  # MacRoman 0xC9 …   0xD2 “   0xD3 ”   0xD4 ‘   0xD5 ’   0x90 ê
  #
  # 0x90 is undefined in CP1252, so it proves Mac Roman on its own.
  # 0x9D is undefined in CP1252 too, but it is also the trailing byte of U+201D,
  # which is why the utf8 fixture below exists.
  ALL = {
    'ascii' => {
      bytes: "name,note\r\nAlice,nothing but plain text here\r\n",
      utf8: 0, lone: {}, expect: nil
    },

    # Regression: every high byte belongs to a UTF-8 sequence, and one of them
    # ends in 0x9D. A raw byte scan reads that as a Mac Roman fingerprint.
    'utf8' => {
      bytes: "name,note\r\nAlice,she said “no” and left…\r\nBob,I’m out\r\n",
      utf8: 4, lone: {}, expect: nil
    },

    'cp1252' => {
      bytes: "name,note\r\nAlice,she said \x93no\x94 and left\x85\r\nBob,I\x92m out\r\n".b,
      utf8: 0, lone: { 0x93 => 1, 0x94 => 1, 0x85 => 1, 0x92 => 1 }, expect: :not_mac
    },

    'macroman' => {
      bytes: "name,note\r\nAlice,she said \xD2no\xD3 at the caf\x90 and left\xC9\r\nBob,I\xD5m out\r\n".b,
      utf8: 0, lone: { 0xD2 => 1, 0xD3 => 1, 0x90 => 1, 0xC9 => 1, 0xD5 => 1 }, expect: 'Mac Roman'
    },

    # The shape of the real upload: UTF-8 quotes alongside lone CP1252 apostrophes.
    'mixed-utf8-cp1252' => {
      bytes: "name,note\r\nAlice,she said “no” about the whole thing\r\nBob,I\x92m out and don\x92t care\r\n".b,
      utf8: 2, lone: { 0x92 => 2 }, expect: :not_mac
    },

    # Same mixing, other single-byte half. Detect has to name the other fallback.
    'mixed-utf8-macroman' => {
      bytes: "name,note\r\nAlice,she said “no” about the whole thing\r\nBob,I\xD5m at the caf\x90 now\r\n".b,
      utf8: 2, lone: { 0xD5 => 1, 0x90 => 1 }, expect: 'Mac Roman'
    }
  }.freeze

  # What each fixture must decode to. Drives the convert assertions.
  DECODED = {
    'cp1252' => "name,note\r\nAlice,she said “no” and left…\r\nBob,I’m out\r\n",
    'macroman' => "name,note\r\nAlice,she said “no” at the cafê and left…\r\nBob,I’m out\r\n",
    'mixed-utf8-cp1252' => "name,note\r\nAlice,she said “no” about the whole thing\r\nBob,I’m out and don’t care\r\n",
    'mixed-utf8-macroman' => "name,note\r\nAlice,she said “no” about the whole thing\r\nBob,I’m at the cafê now\r\n"
  }.freeze

  FALLBACK = {
    'cp1252' => 'CP1252', 'mixed-utf8-cp1252' => 'CP1252',
    'macroman' => 'MACROMAN', 'mixed-utf8-macroman' => 'MACROMAN'
  }.freeze
end
