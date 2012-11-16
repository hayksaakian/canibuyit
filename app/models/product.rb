class Product
  include Mongoid::Document
  include Mongoid::Slug

  field :name, :type => String
  field :available, :type => Boolean
  field :url, :type => String
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

  def email
  	require 'rest_client'
  	api_key = ENV['MAILGUN_API_KEY']
		api_url = "https://api:"+api_key+\
		"@api.mailgun.net/v2/mailgun.net"

		RestClient.post api_url+"/messages", 
	    :from => "ev@example.com",
	    :to => "hayk.saakian@gmail.com",
	    :subject => "This is subject",
	    :text => "Text body",
	    :html => "<b>HTML</b> version of the body!"
  end
end
