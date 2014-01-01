require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe AlbumsController do
  before(:each) do
    @me = create(:user)
    sign_in @me

    controller.stub :current_user => @me
  end

  after(:each) do
    logout(:user)
    Warden.test_reset!
  end

  # This should return the minimal set of attributes required to create a valid
  # Album. As you add validations to Album, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {
    "title" => "MyString",
    "user_id" => 1
  } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AlbumsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "will only get a user's albums when a username is in the params" do
      album = Album.create! valid_attributes
      another_album = Album.create!({ title: 'x', user_id: 2 })
      Album.count.should eq(2)

      get :index, { username: @me.username }, valid_session
      assigns(:albums).should eq([album])
      assigns(:albums).should_not include(another_album)
    end
  end

  describe "GET index" do
    before(:each) do
      @public_album = Album.create! ({ title:   'My public album',
                                       user_id: 1,
                                       public: true })
      @private_album = Album.create! ({ title:  'My private album',
                                        user_id: 1,
                                        public: false })
    end

    context 'when logged in' do
      before(:each) do
        get :index, { username: @me.username }, valid_session
      end

      it 'will assign my public and private albums' do
        expect(assigns(:album)).to eq([@public_album, @private_album])
      end
    end

    context 'when logged out' do
      before(:each) do
        logout(:user)
        get :index, { username: @me.username }, valid_session
      end

      it 'will only assign my public albums' do
        expect(assigns(:album)).to eq([@public_album])
      end
    end
  end

  describe "GET show" do
    it "assigns the requested album as @album" do
      album = Album.create! valid_attributes
      get :show, {:key => album.to_param}, valid_session
      assigns(:album).should eq(album)
    end
  end

  describe "GET new" do
    it "assigns a new album as @album" do
      get :new, {}, valid_session
      assigns(:album).should be_a_new(Album)
    end
  end

  describe "GET edit" do
    it "assigns the requested album as @album" do
      album = Album.create! valid_attributes
      get :edit, {:key => album.to_param}, valid_session
      assigns(:album).should eq(album)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Album" do
        expect {
          post :create, {:album => valid_attributes}, valid_session
        }.to change(Album, :count).by(1)
      end

      it "assigns a newly created album as @album" do
        post :create, {:album => valid_attributes}, valid_session
        assigns(:album).should be_a(Album)
        assigns(:album).should be_persisted
      end

      it "redirects to the created album" do
        post :create, {:album => valid_attributes}, valid_session
        response.should redirect_to(Album.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved album as @album" do
        # Trigger the behavior that occurs when invalid params are submitted
        Album.any_instance.stub(:save).and_return(false)
        post :create, {:album => { "title" => "invalid value" }}, valid_session
        assigns(:album).should be_a_new(Album)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Album.any_instance.stub(:save).and_return(false)
        post :create, {:album => { "title" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end

    describe "album image creation" do
      before(:each) do
        logout(:user)
        # Can't create album images if I don't have images in the first place.
        @me_with_image = create(:user_with_image)
        sign_in(@me_with_image)
        controller.stub :current_user => @me_with_image
      end

      it 'creates album images for the new album' do
        valid_attributes_with_images = valid_attributes
        valid_attributes_with_images[:add_to_album] = true
        valid_attributes_with_images[:selected] = [1]

        post :create, { :album => valid_attributes_with_images }

        assigns(:album).album_images.count.should eq(1)
        assigns(:album).album_images.first.should be_persisted

        AlbumImage.first.album.should eq(assigns(:album))
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested album" do
        album = Album.create! valid_attributes
        # Assuming there are no other albums in the database, this
        # specifies that the Album created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Album.any_instance.should_receive(:update).with({ "title" => "MyString" })
        put :update, {:key => album.to_param, :album => { "title" => "MyString" }}, valid_session
      end

      it "assigns the requested album as @album" do
        album = Album.create! valid_attributes
        put :update, {:key => album.to_param, :album => valid_attributes}, valid_session
        assigns(:album).should eq(album)
      end

      it "redirects to the album" do
        album = Album.create! valid_attributes
        put :update, {:key => album.to_param, :album => valid_attributes}, valid_session
        response.should redirect_to(album)
      end
    end

    describe "with invalid params" do
      it "assigns the album as @album" do
        album = Album.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Album.any_instance.stub(:save).and_return(false)
        put :update, {:key => album.to_param, :album => { "title" => "invalid value" }}, valid_session
        assigns(:album).should eq(album)
      end

      it "re-renders the 'edit' template" do
        album = Album.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Album.any_instance.stub(:save).and_return(false)
        put :update, {:key => album.to_param, :album => { "title" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested album" do
      album = Album.create! valid_attributes
      expect {
        delete :destroy, {:key => album.to_param}, valid_session
      }.to change(Album, :count).by(-1)
    end

    it "redirects to the albums list" do
      album = Album.create! valid_attributes
      delete :destroy, {:key => album.to_param}, valid_session
      response.should redirect_to(albums_url)
    end
  end

end
