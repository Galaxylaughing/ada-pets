require 'test_helper'

describe PetsController do
  PET_FIELDS = %w(id age name human).sort
  
  describe "index" do
    it "responds with JSON and success" do
      get pets_path
      
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :ok
    end
    
    it "responds with an array of pet hashes" do
      # Act
      get pets_path
      
      # Get the body of the response
      body = JSON.parse(response.body)
      
      # Assert
      expect(body).must_be_instance_of Array
      body.each do |pet|
        expect(pet).must_be_instance_of Hash
        expect(pet.keys.sort).must_equal PET_FIELDS
      end
    end
    
    it "will respond with an empty array when there are no pets" do
      # Arrange
      Pet.destroy_all
      
      # Act
      get pets_path
      body = JSON.parse(response.body)
      
      # Assert
      expect(body).must_be_instance_of Array
      expect(body).must_equal []
    end
  end
  
  describe "show" do
    let(:pet) {
      pets(:one)
    }
    
    it "responds with JSON and success" do
      get pet_path(pet.id)
      
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :ok
    end
    
    it "responds with a hash of pet data" do
      get pet_path(pet.id)
      
      body = JSON.parse(response.body)
      
      expect(body).must_be_instance_of Hash
      expect(body.keys.sort).must_equal PET_FIELDS
      expect(body["id"]).must_equal pet.id
      expect(body["age"]).must_equal pet.age
      expect(body["human"]).must_equal pet.human
      expect(body["name"]).must_equal pet.name
    end
    
    it "will respond with empty hash and not_found if the pet does not exist" do
      get pet_path(-1)
      
      expect(response.header['Content-Type']).must_include 'json'
      must_respond_with :not_found
      
      body = JSON.parse(response.body)
      
      expect(body).must_be_instance_of Hash
      expect(body["ok"]).must_equal false
      expect(body.keys).must_include "errors"
    end
  end
end
