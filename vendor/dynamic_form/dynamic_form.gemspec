Gem::Specification.new do |s|
  s.name = %q{dynamic_form}
  s.version = "1.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = ">= 2.7.0", "< 5"
  s.authors = ["Joel Moss"]
  s.date = %q{2010-09-05}
  s.description = %q{DynamicForm holds a few helper methods to help you deal with your Rails3 models. It includes the stripped out methods from Rails 2; error_message_on and error_messages_for. It also brings in the functionality of the custom-err-messages plugin, which provides more flexibility over your model error messages.}
  s.email = %q{mathieu.jobin@gmail.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "MIT-LICENSE",
     "README.md",
     "Rakefile",
     "dynamic_form.gemspec",
     "init.rb",
     "lib/action_view/helpers/dynamic_form.rb",
     "lib/action_view/locale/en.yml",
     "lib/active_model/dynamic_errors.rb",
     "lib/active_model/locale/en.yml",
     "lib/dynamic_form.rb",
     "test/dynamic_form_i18n_test.rb",
     "test/dynamic_form_test.rb",
     "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/rails/dynamic_form}
  s.homepage = %q{http://github.com/joelmoss/dynamic_form}
  s.homepage = %q{https://github.com/payrollhero/dynamic_form}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = ">= 1.3.7"
  s.summary = %q{DynamicForm holds a few helper methods to help you deal with your Rails3 models}
  s.test_files = [
    "test/dynamic_form_i18n_test.rb",
     "test/dynamic_form_test.rb",
     "test/test_helper.rb"
  ]

  s.add_runtime_dependency 'actionview', '> 5.2.0'
  s.add_runtime_dependency 'activemodel', '> 5.2.0'
  s.add_development_dependency(%q<benchmark>, [">= 0"])
  s.add_development_dependency(%q<bigdecimal>, [">= 0"])
  s.add_development_dependency(%q<byebug>, [">= 0"])
  s.add_development_dependency(%q<logger>, [">= 0"])
  s.add_development_dependency(%q<mocha>, [">= 0"])
  s.add_development_dependency(%q<mutex_m>, [">= 0"])
  s.add_development_dependency(%q<test-unit>, [">= 0"])
  s.add_development_dependency(%q<test-unit-rails>, [">= 0"])
  s.add_development_dependency(%q<test-unit-full>, [">= 0"])
end
