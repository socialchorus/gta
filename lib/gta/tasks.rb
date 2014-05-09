require 'gta'

load "#{File.dirname(__FILE__)}/tasks/deploy.rake"
load "#{File.dirname(__FILE__)}/tasks/gta.rake"
load "#{File.dirname(__FILE__)}/tasks/heroku_db.rake"
load "#{File.dirname(__FILE__)}/tasks/hotfix.rake"
load "#{File.dirname(__FILE__)}/tasks/heroku.rake"
load "#{File.dirname(__FILE__)}/tasks/diff.rake"
