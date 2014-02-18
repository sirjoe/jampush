require "net/http"
require "uri"
require "yaml"

module Jampush
  class Base
  	attr_accessor :ctrl, :subject, :target_type, :within, :schedule_type

  	def initialize(type)
	  config = YAML.load_file('jampush.yaml')
	  #puts config
	  @ctrl = 'sendpush_alert'
	  @rest_code = config['rest_code']
	  @appkey = config['appkey']
	  @target_type = 'all'
	  @subject = 'I want a happy life'
	  @within = 'no'
	  @schedule_type = 'now'
	end

	def push
    post_body = Hash[instance_variables.map { |name| [ name.to_s[1..-1], instance_variable_get(name)] } ] 
    body = URI.encode_www_form(post_body)

    uri = URI.parse('https://api.jampush.com.tw/rest-api.php')
    response = Net::HTTP.post_form(uri, post_body)
    puts response.code 
    puts response.body
	end

  end




  def self.message(message)
  	Base.new(:alert)
  end


end

if __FILE__ == $0
  message = Jampush::message(:alert)
  message.push
end