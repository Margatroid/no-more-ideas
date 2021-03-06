module AuthHelper
  def register(email, key)
    visit '/register'
    pass = 'password'

    fill_in 'Email',                 :with => email
    fill_in 'Password',              :with => pass
    fill_in 'Password confirmation', :with => pass
    fill_in 'Username',              :with => SecureRandom.hex

    fill_in 'Invite key', :with => key if key

    click_button 'Register'
  end

  def login(email, pass)
    visit '/login'
    fill_in 'Email',    :with => email
    fill_in 'Password', :with => pass
    click_button 'Sign in'
  end
end

module UploadHelper
  def upload_test_file
    upload_file('test_image.png')
  end

  def upload_test_another_file
    upload_file('sushi.jpg')
  end

  private
  def upload_file(filename)
    visit '/'
    attach_file('File', File.expand_path("spec/fixtures/#{ filename }"))
    click_button 'Upload image'
    Image.last.update_attribute(:public, true)
  end
end

module PathHelper
  def get_image_path(image)
    Rails.application.routes.url_helpers.image_path(image.key)
  end
end