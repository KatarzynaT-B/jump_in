# require_relative '../spec_helper.rb'

# describe "Resetting password" do
#   let!(:user) { FactoryGirl.create(:user) }

#   it 'allows user to send reset password link' do
#     visit new_password_resets_path
#     expect(page).to have_content('Reset Password Page')
#     fill_in 'email', with: user.email
#     click_button 'Reset password'
#     expect(page).to have_content('Login Page')
#   end

#   it 'redirects to login path after password update' do
#     user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
#     visit edit_password_resets_path(token: user.password_reset_token)
#     expect(page).to have_content("Edit for PasswordReset")
#     fill_in "password", with: 'new_password'
#     fill_in "password_confirmation", with: 'new_password'
#     click_button "Set new password"
#     expect(page).to have_content("Login Page")
#   end

#   it 'doest allow for password reset if token too old' do
#     user.update_attribute(:password_reset_token, Base64.urlsafe_encode64("#{SecureRandom.hex(10)}.#{5.days.ago}"))
#     visit edit_password_resets_path(token: user.password_reset_token)
#     expect(page).to have_content("password-reset-token is too old")
#   end

#   it 'displays edit page when password does not match password_confirmation' do
#     user.update_attribute(:password_reset_token, JumpIn::Tokenator.generate_token)
#     visit edit_password_resets_path(token: user.password_reset_token)
#     expect(page).to have_content('Edit for PasswordReset')
#     fill_in 'password', with: 'new_password'
#     fill_in 'password_confirmation', with: 'another_password'
#     click_button 'Set new password'
#     expect(page).to have_content('Edit for PasswordReset')
#   end
# end
