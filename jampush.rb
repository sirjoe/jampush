require "net/http"
require "uri"
require "yaml"

module Jampush
  class Base
    attr_accessor :config, :content, :target, :schedule

  	def initialize
      load_config
  	  
  	  @target_type = 'all'
  	  @subject = 'I want a happy life'
  	  @within = 'no'
  	  @schedule_type = 'now'
	  end

    # param: hash { success:proc, failure:proc }
  	def push(callbacks)
      begin
        raise InsufficientCallbackHandlerError.new if callbacks[:success].nil? || callbacks[:failure].nil?
        validate_required_fields_for(:content)
        puts 'current class ---'
        puts self.class.class_variables

        post_body = Hash[instance_variables.map { |name| [ name.to_s[1..-1], instance_variable_get(name)] } ] 
        body = URI.encode_www_form(post_body)

        puts body

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
        puts e.message
        puts 'Error occured while generating push notification via Jampush'

      end #eo begin-rescue-end
  	end #eo push

    private

    def load_config
      @config = YAML.load_file('jampush.yaml')
      @rest_code = @config['rest_code']
      @appkey = @config['appkey']
    end #eo load_config

    def validate_required_fields_for(type)
      required_fields = self.class.class_variable_get("@@#{type}_fields")
      input_fields = instance_variable_get("@#{type}")

      input_fields.each do |key, value|
        raise UnidentifiedKeyError unless required_fields.has_key?(key)
      end

      required_fields.each do |key, value|
        raise MissingRequiredFieldsError unless input_fields.has_key?(key) if value
      end
    end #eo validate_required_fields_for


  end #eo class Base

  class Alert < Base 
    @@content_fields = {
      :subject => true,
      :button => false,
      :custom => false
    }

    def initialize
      @ctrl = 'sendpush_alert'
      super
    end

    

  end

  class InsufficientCallbackHandlerError < StandardError
    attr_accessor :reason

    def initialize
      @reason = 'Missing either success/failure handler.'
    end
  end

  class UnidentifiedKeyError < StandardError
    attr_accessor :reason

    def initialize
      @reason = 'You have provided a key that is not recognized in Jampush api.'
    end
  end

  class MissingRequiredFieldsError < StandardError
    attr_accessor :reason

    def initialize
      @reason = 'Imcomplete required field(s) in the push request post body.'
    end
  end

  def self.message(type)
  	#Base.new(:alert)
    case type

    when :alert
      Alert.new
    else
      puts 'Invalid message type selected'
    end
  end

end #eo module Jampush

if __FILE__ == $0
  message = Jampush::message(:alert)

  message.content = {
    :subject => "Please give me a job!"
  }

  success_hanlder = Proc.new do |response|
    puts 'success_hanlder ' + response.code.to_s
  end

  failure_handler = Proc.new do |response|
    puts 'failure_handler ' + response.code.to_s
  end

  message.push ( { :success => success_hanlder, :failure => failure_handler } )

end



