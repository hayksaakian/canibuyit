class Product
  include Mongoid::Document
  field :name, :type => String
  field :available, :type => Boolean
  field :url, :type => String

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
  	API_KEY = ENV['MAILGUN_API_KEY']
		API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/mailgun.net"
		RestClient.post API_URL+"/messages", 
	    :from => "ev@example.com",
	    :to => "hayk.saakian@gmail.com",
	    :subject => "This is subject",
	    :text => "Text body",
	    :html => "<b>HTML</b> version of the body!"
  end
end
