load 'protobuf/tasks/compile.rake'

task :compile do
  args = %w(skyjam defs lib ruby .pb.rb)
  ::Rake::Task['protobuf:compile'].invoke(*args)
end
