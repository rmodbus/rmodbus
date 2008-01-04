require 'rbconfig'
require 'ftools'

begin
  require 'rubygems'
rescue Exception
end

begin
 require 'spec/rake/spectask'

 Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['-c']
    t.spec_files = FileList['test/**/*_spec.rb']
    t.rcov = true 
  end
rescue Exception 
  puts 'RSpec not found, please install rspec for run testes'
end

include Config

task :install do

  sitedir = CONFIG['sitelibdir']
  rmodbus_dest = File.join(sitedir, 'rmodbus')

  File::makedirs(rmodbus_dest, true)
  File::chmod(0755, rmodbus_dest)

  files = Dir.chdir('lib') { Dir['**/*.rb'] }

  files.each do |fn|
    fn_dir = File.dirname(fn)
    target_dir = File.join(sitedir, fn_dir)
    File::makedirs(target_dir) unless File.exist?(target_dir)
    File::install(File.join('lib', fn), File.join(sitedir, fn), 0644, true)
  end

end
