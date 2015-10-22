module JumpIn::Generators
  class LastLoggedIn < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)
    desc 'Creates template for LastLoggedIn strategy'

    def copy_initializer
      template 'last_logged_in.rb', 'lib/jump_in/last_logged_in.rb'
      puts 'Created JumpIn::LastLoggedIn template.'
    end
  end
end
