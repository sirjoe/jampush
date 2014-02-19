require './base'

module Jampush
  class Alert < Jampush::Base
    @@content_fields = {
      :subject => true,
      :button => false,
      :custom => false
    }

    def initialize
      @ctrl = 'sendpush_alert'
      super
    end

  end #eo Alert<Base
end

if __FILE__ == $0

  message = Jampush::Alert.new

  message.content = {
    :subject => "I love you sweetie!",
    :button => "gan",
    :custom => "cha"
  }

  message.target = {
    :target_type => 'all',
    :within => 'no'
  }

  message.schedule = {
    :schedule_type => 'now'
  }



  success_hanlder = Proc.new do |response|
    puts 'success_hanlder ' + response.code.to_s
  end

  failure_handler = Proc.new do |response|
    puts 'failure_handler ' + response.code.to_s
  end

  message.push ( { :success => success_hanlder, :failure => failure_handler } )

end