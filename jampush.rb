require "net/http"
require "uri"
require "yaml"

module Jampush
  class Base
  	attr_accessor :ctrl, :subject, :target_type, :within, :schedule_type

  	def initialize(type)
	  @config = YAML.load_file('jampush.yaml')
	  #puts config
	  @ctrl = 'sendpush_alert'
	  @rest_code = @config['rest_code']
	  @appkey = @config['appkey']
	  @target_type = 'all'
	  @subject = 'I want a happy life'
	  @within = 'no'
	  @schedule_type = 'now'
	end

  # param: hash { success:proc, failure:proc }
	def push(callbacks)

    return if callbacks[:success].nil? || callbacks[:failure].nil?

    post_body = Hash[instance_variables.map { |name| [ name.to_s[1..-1], instance_variable_get(name)] } ] 
    body = URI.encode_www_form(post_body)

    uri = URI.parse(@config['url'])
    response = Net::HTTP.post_form(uri, post_body)
    puts response.code 
    puts response.body

    if response.code.eql? '200'
      callbacks[:success].call response
    else
      callbacks[:failure].call response
    end
	end

  end




  def self.message(message)
  	Base.new(:alert)
  end


end

if __FILE__ == $0
  message = Jampush::message(:alert)

  success_hanlder = Proc.new do |response|
    puts 'success_hanlder ' + response.code.to_s
  end

  failure_handler = Proc.new do |response|
    puts 'failure_handler ' + response.code.to_s
  end

  message.push ( { :success => success_hanlder, :failure => failure_handler } )
  #message.push 
  #message.push ( { :success => success_hanlder } )
end



