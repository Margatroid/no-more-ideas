require 'spec_helper'
include UploadHelper, UserFactory, PathHelper

describe 'homepage behaviour', :type => :feature do
  before { visit '/' }
  it "loads a page with the site's name" do
    expect(page).to have_content 'uploadstuffto.me'
  end

  it 'will display an upload field if and only if logged in' do
    user = Invite.create(:description => 'Test')
      .users
      .create(:email => 'test@test.com', :password => 'panzer vor')

    login_as(user, :scope => :user)
    visit '/'
    expect(page).to have_content 'Upload image(s)'

    logout(:user)
    visit '/'
    expect(page).not_to have_content 'Upload image(s)'
  end

  after(:each) do
    logout(:user)
    Warden.test_reset!
  end
end

describe 'top navigation bar behaviour', :type => :feature do
  before { visit '/' }

  it 'has a link back to the homepage' do
    home_link = page.find('#homepage_link')
    home_link[:href].should eq(root_path)
  end
end

describe 'my recent uploads widget', :type => :feature do
  it 'will show what I just uploaded in the widget' do
    login_as_registered_user
    upload_test_file

    visit '/'
    recent_upload = page.first('#my_recent_uploads a')
    recent_upload[:href].should eq(
      Rails.application.routes.url_helpers.image_path(Image.first.key)
    )

    thumb = page.first('#my_recent_uploads img')
    thumb[:src].should eq(Image.first.file.url(:thumb))
  end
end

describe "everyone else's recent uploads widget", :type => :feature do
  widget_id = '#recent_uploads'

  before(:each) do
    @me = login_as_registered_user
    upload_test_file
    logout(:user)
    @someone_else = login_as_registered_user
    upload_test_another_file
    logout(:user)

    login_as(@me, :scope => :user)
    visit '/'
  end

  it 'should not show your own upload' do
    my_upload_thumb = @me.images.first.file.path(:thumb)
    my_upload_url   = get_image_path(@me.images.first)
    images_in_widget = page.all(:css, "#{ widget_id } .small-tile img")
    images_in_widget.count.should eq (1)
    images_in_widget.each do |image|
      image[:src].should_not eq(my_upload_thumb)
      image[:href].should_not eq(my_upload_url)
    end
  end

  it "should show someone else's upload" do
    widget        = page.first("#{ widget_id } .small-tile img")
    expected_href = get_image_path(@someone_else.images.first)
    expected_src  = @someone_else.images.first.file.url(:thumb)

    page.all(:css, "#{ widget_id } .small-tile a").count.should eq(1)
    # Expect first and only image in widget to link to someone else's upload.
    page.first("#{ widget_id } .small-tile a")[:href].should eq(expected_href)
    # Expect first and only image in widget to have correct source thumbnail.
    page.first("#{ widget_id } .small-tile a img")[:src].should eq(expected_src)
  end

  it 'should show both uploads when logged out' do
    logout(:user)
    visit '/'
    images = page.all(:css, "#{ widget_id } .small-tile a")
    page.all(:css, "#{ widget_id } .small-tile a").count.should eq(2)

    images.first[:href].should_not eq(images.last[:href])
  end

  after(:each) do
    logout(:user)
    Warden.test_reset!
  end
end

describe 'straight after new account creation', :type => :feature do
  it 'should not show my recent uploads widget if I have no images' do
    user = login_as_registered_user
    visit '/'

    user.images.count.should eq(0)
    page.should have_no_content('My recent uploads')
  end
end