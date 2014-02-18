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

	def send_push
    post_body = Hash[instance_variables.map { |name| [ name.to_s[1..-1], instance_variable_get(name)] } ] 
    puts URI.encode_www_form(post_body)
	end

  end




  def self.message(message)
  	Base.new(:alert)
  end


end

if __FILE__ == $0
  message = Jampush::message(:alert)
  message.send_push
end