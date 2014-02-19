require "net/http"
require "uri"
require "yaml"

module Jampush
  class Base
    attr_accessor :content, :target, :schedule

    @@target_fields = {
      :target_type => true,
      :device_ids => false,
      :mac_address => false,
      :app_ids => false,
      :device_type => false,
      :within => true,
      :within_address => false,
      :within_axis => false,
      :within_range => false,
      :within_limit => false,
      :tags => false
    }

    @@schedule_fields = {
      :schedule_type => true,
      :schedule_start => false,
      :schedule_offset => false,
      :frequency => false,
      :frequency_type => false,
      :frequency_times => false,
      :repeat => false,
      :repeat_delay => false,
      :repeat_times => false,
      :repeat_trigger => false
    }
    
    def initialize
      load_config
	  end

    # param: hash { success:proc, failure:proc }
  	def push(callbacks)
      begin
        raise InsufficientCallbackHandlerError.new if callbacks[:success].nil? || callbacks[:failure].nil?
        
        [:content, :target, :schedule].each { |i| validate_required_fields_for(i) }

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

      rescue InputFieldsNotProvidedError => e
        puts e.message
        puts 'Reason: ' << e.reason

      rescue UnidentifiedKeyError => e
        puts e.message
        puts 'Reason: ' << e.reason

      rescue MissingRequiredFieldsError => e
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

      raise InputFieldsNotProvidedError.new(type) unless input_fields

      input_fields.each do |key, value|
        raise UnidentifiedKeyError.new unless required_fields.has_key?(key)
      end

      required_fields.each do |key, value|
        raise MissingRequiredFieldsError.new unless input_fields.has_key?(key) if value
      end

      input_fields.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end #eo validate_required_fields_for

  end #eo class Base

  class InputFieldsNotProvidedError < Exception
    attr_accessor :reason

    def initialize(type)
      @reason = 'Input field(s) not provided for "' << type.to_s << '"'
    end
  end

  class InsufficientCallbackHandlerError < Exception
    attr_accessor :reason

    def initialize
      @reason = 'Missing either success/failure handler.'
    end
  end

  class UnidentifiedKeyError < Exception
    attr_accessor :reason

    def initialize
      @reason = 'You have provided a key that is not recognized in Jampush api.'
    end
  end

  class MissingRequiredFieldsError < Exception
    attr_accessor :reason

    def initialize
      @reason = 'Imcomplete required field(s) in the push request post body.'
    end
  end

end #eo module Jampush





