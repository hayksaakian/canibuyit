require 'open-uri'
class Product
  include Mongoid::Document
  include Mongoid::Slug
  include Rails.application.routes.url_helpers

  field :name, :type => String
  field :available, :type => Boolean, :default => false
  field :prev_available, :type => Boolean
  field :url, :type => String
  field :proxy_ip, :type => String
  field :proxy_port, :type => String
  field :addresses, :type => Array, :default => []
  slug :name

  # trying 195.102.23.53:80
  # a UK proxy

  def check_available
    self.update_attribute(:prev_available, self.available)
  	url = URI.parse(self.url) 
  	#extra BS because google's play redirects to a https url regardless
    if self.proxy_port != nil and self.proxy_ip != nil
      # puts 'using proxy'
      doc = Nokogiri::HTML(open(url, :proxy => 'http://'+self.proxy_ip+':'+self.proxy_port))

      response = doc.to_s
    else
      # puts 'no proxy (using US ip)'
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url.request_uri)
      response = http.request(request).body      
    end
  	# don't actually need nokogiri here, a regex will work fine
  	# doc = Nokogiri::HTML(response)
  	# response = doc.xpath('SOMEXPATH').to_s
  	# regex to see if the page contains 'sold out' anywhere
  	if response =~ /google/ and response =~ /Sold Out/im or response =~ /sold-out/im
  		#sold out does exist
  		self.update_attribute(:available, false)
  		return false
  	else
  		self.update_attribute(:available, true)
  		#only tell everyone if it was not previously available
  		if self.prev_available != self.available
  			self.tell_subscribers_available
  		end
  		return true
  	end
  end

  def self.update_availabilities
  	Product.all.each do |pr|
  		pr.delay.check_available
  	end
  end

	require 'rest_client'
  def tell_subscribers_available
  	api_key = ENV['MAILGUN_API_KEY']
		api_url = "https://api:"+api_key+"@api.mailgun.net/v2/app9271104.mailgun.org"
		self.addresses.each do |address|
			RestClient.post api_url+"/messages", 
		    :from => "notification@canibuyanexus4.info",
		    :to => address,
		    :subject => self.name+" just became available",
		    :text => "You can buy it at "+self.url+" . If you want to stop recieving notifications, submit your email at "+product_path(self, :host => 'canibuyanexus4.info', :only_path => false).to_s
		end
  end
  handle_asynchronously :tell_subscribers_available
end
