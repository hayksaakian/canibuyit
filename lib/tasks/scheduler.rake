desc "This task is called by the Heroku scheduler add-on to update availabilities"
task :update => :environment do
  puts "Updating availabilities..."
  Product.update_availabilities
  puts "All updates queued."
end