# lib/tasks/create_keep_files.rake
namespace :setup do
  desc "Create .keep files in necessary empty folders"
  task :keep_files => :environment do
    %w[
      log
      tmp
      tmp/pids
      tmp/storage
      storage
    ].each do |dir|
      path = Rails.root.join(dir, ".keep")
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path) unless File.exist?(path)
      puts "✔ Created: #{path}"
    end
  end
end
