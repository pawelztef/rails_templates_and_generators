bootstrap_simple_form_flag = false
root_controller_name = false
materialize_flag = false

if yes? "Do you want a root controller?"
  root_controller_name = ask("Please specify name").underscore
end
if yes? "Do you want to install bootstrap?"
  bootstrap_simple_form_flag = true
elsif yes? "Do you want to install materialize?"
  materialize_flag = true
end


#################################################
################## Adding gems ##################

gem "font-awesome-rails"
gem "simple_form"
gem 'jquery-turbolinks'
gem "gritter", "1.2.0"
gem 'faker'
gem_group :development do
  gem 'guard-livereload', '~> 2.5', require: false
  gem "rack-livereload"
  gem "letter_opener"
end
gem_group :development, :test do
  gem 'rack-mini-profiler'
  gem 'pry-rails'
  gem 'pry-byebug'
end

if bootstrap_simple_form_flag 
  gem 'bootstrap', '~> 4.0.0.alpha6'
  add_source 'https://rails-assets.org' do
    gem 'rails-assets-tether', '>= 1.3.3'
  end
end

if materialize_flag
  gem 'materialize-sass'
  gem 'material_icons'
end

#################################################
############## Setting config files #############
 
gsub_file 'Gemfile', "gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]", 
  "#gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]"

inject_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-'RUBY'
  # configuration for mailer and letter_opener gem for opening mails in browser
  config.action_mailer.delivery_method = :letter_opener

  RUBY
end

create_file "TODO"
create_file ".pryrc"
inject_into_file '.pryrc', after: "" do <<-'RUBY'
if defined?(PryRails)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'e', 'exit'
end
RUBY
end

#################################################
########### Setting application files ###########
 
remove_file "app/assets/stylesheets/application.css"
create_file "app/assets/stylesheets/application.sass"
run "echo '@import \"font-awesome\"' >> app/assets/stylesheets/application.sass"
run "echo '@import \"bootstrap\"' >> app/assets/stylesheets/application.sass" if bootstrap_simple_form_flag
run "echo '@import \"#{root_controller_name}\"' >> app/assets/stylesheets/application.sass" if root_controller_name 

inject_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-'RUBY'
   config.sass.preferred_syntax = :sass
RUBY
end

inject_into_file 'config/environments/development.rb', after: "Rails.application.configure do\n" do <<-'RUBY'
   config.generators.javascript_engine = :js
RUBY
end

if bootstrap_simple_form_flag
  inject_into_file 'app/assets/javascripts/application.js', after: "//= require jquery\n" do <<-'RUBY'
//= require tether
//= require bootstrap-sprockets
  RUBY
  end
end

if materialize_flag
  run "echo '@import \"materialize\"' >> app/assets/stylesheets/application.sass"
  run "echo '@import \"material_icons\"' >> app/assets/stylesheets/application.sass"
  inject_into_file 'app/assets/javascripts/application.js', before: "//= require_tree .\n" do <<-'RUBY'
//= require materialize-sprockets
  RUBY
  end
end
 
#################################################
####### Run bundle commands and etc. ############

run "bundle install"
run "bundle exec guard init"

if bootstrap_simple_form_flag 
  generate "simple_form:install --bootstrap"
elsif
  generate "simple_form:install"
end


if root_controller_name
  generate :controller, "#{root_controller_name} index"
  route "root to: '#{root_controller_name}\#index'"
end


#################################################
############ Setting Git ########################
 
# git :init
# create_file '.git/safe'
# append_file '.git/safe', 'PATH=".git/safe/../../bin:$PATH"'
# git add: "--all"
# git commit: "-m init"

#################################################


