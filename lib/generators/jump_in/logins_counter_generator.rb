module JumpIn::Generators
  class LoginsCounter < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)
    desc 'Creates template for LoginsCounter strategy'

    def copy_initializer
      template 'logins_counter.rb', 'lib/jump_in/logins_counter.rb'
      puts 'Created JumpIn::LoginsCounter template.'
    end
  end
end
