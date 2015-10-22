module JumpIn::Generators
  class LastLoggedOut < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)
    desc 'Creates template for LastLoggedOut strategy'

    def copy_initializer
      template 'last_logged_out.rb', 'lib/jump_in/last_logged_out.rb'
      puts 'Created JumpIn::LastLoggedOut template.'
    end
  end
end
