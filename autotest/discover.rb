Autotest.add_discovery { %w(rails rspec2) }

Autotest.add_hook :initialize do |at|
  at.remove_exception(%r%^([\.\/]*)?config/%)

  at.clear_mappings

  at.add_mapping(%r%^spec/(models|controllers|helpers|lib)?.*_spec\.rb$%) { |filename, _|
    filename
  }

  at.add_mapping(%r%^app/(models|controllers|helpers|lib)/(?:.*/)?(.*)\.rb$%) { |_, m|
    if m[1] != "models" && m[2] =~ /^application/
      at.files_matching(%r%^spec/#{m[1]}/.*_spec\.rb$%)
    else
      ["spec/#{m[1]}/#{m[2]}_spec.rb"]
    end
  }

  at.add_mapping(%r%^lib/mezu\.rb$%) {
    at.files_matching %r%^spec/.*_spec\.rb$%
  }

  at.add_mapping(%r%^config/routes\.rb$%) {
    at.files_matching %r%^spec/controllers/.*_spec\.rb$%
  }

  at.add_mapping(%r%^spec/(schema|spec_helper)\.rb$%) {
    at.files_matching %r%^spec/.*_spec\.rb$%
  }
end
