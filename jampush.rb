require "net/http"
require "uri"
require "yaml"

module Jampush
  class Base
  	#attr_accessor :ctrl, :subject, :target_type, :within, :schedule_type
    attr_accessor :config, :content, :target, :schedule

  	def initialize(type)
      load_config
  	  @ctrl = 'sendpush_alert'
  	  @target_type = 'all'
  	  @subject = 'I want a happy life'
  	  @within = 'no'
  	  @schedule_type = 'now'
	  end

    # param: hash { success:proc, failure:proc }
  	def push(callbacks)
      begin
        raise InsufficientCallbackHandlerError.new if callbacks[:success].nil? || callbacks[:failure].nil?

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
      rescue InsufficientCallbackHandlerError => e
        puts e.message
        puts 'Reason: ' << e.reason
      rescue Exception => e
        puts 'Error occured while generating push notification via Jampush'
      end
  	end

    private

    def load_config
      @config = YAML.load_file('jampush.yaml')
      @rest_code = @config['rest_code']
      @appkey = @config['appkey']
    end

    def validate_mandatory_keys_for(section)

    end

  end #eo class Base

  class InsufficientCallbackHandlerError < StandardError
    attr_accessor :failed_action, :reason

    def initialize
      @reason = 'Missing either success/failure handler'
    end
  end

  def self.message(message)
  	Base.new(:alert)
  end

end #eo module Jampush

if __FILE__ == $0
  message = Jampush::message(:alert)

  success_hanlder = Proc.new do |response|
    puts 'success_hanlder ' + response.code.to_s
  end

  failure_handler = Proc.new do |response|
    puts 'failure_handler ' + response.code.to_s
  end

  message.push ( { :success => success_hanlder, :failure => failure_handler } )

end



