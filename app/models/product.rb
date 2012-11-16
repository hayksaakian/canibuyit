require 'open-uri'
class Product
  include Mongoid::Document
  include Mongoid::Slug
  include Rails.application.routes.url_helpers

  field :name, :type => String
  field :available, :type => Boolean
  field :url, :type => String
  field :addresses, :type => Array, :default => []
  slug :name

  def check_available
  	url = URI.parse(self.url) 
  	#extra BS because google's play redirects to a https url regardless
  	http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)
  	response = http.request(request).body
  	# don't actually need nokogiri here, a regex will work fine
  	# doc = Nokogiri::HTML(response)
  	# response = doc.xpath('SOMEXPATH').to_s
  	if response =~ /Sold Out/im
  		#sold out does exist
  		self.update_attribute(:available, false)
  		return false
  	else
  		self.update_attribute(:available, true)
  		return true
  	end
  end

	require 'rest_client'
  def tell_subscribers_available
  	api_key = ENV['MAILGUN_API_KEY']
		api_url = "https://api:"+api_key+"@api.mailgun.net/v2/app9271104.mailgun.org"
		self.addresses.each do |address|
			RestClient.post api_url+"/messages", 
		    :from => "notification@canibuyanexus4.info",
		    :to => "hayk.saakian@gmail.com",
		    :subject => self.name+" just became available",
		    :text => "Buy it at "+self.url+" If you want to stop recieving notifications, submit your email at "+product_path(self, :only_path => false).to_s
		end
  end
end
