require 'test_helper'

describe PetsController do
  PET_FIELDS = %w(id age name human).sort
  
  describe "index" do
    it "responds with JSON, success, and array of pet hashes" do
      get pets_path
      
      body = check_response(expected_type: Array, expected_status: :ok)
      body.each do |pet|
        expect(pet).must_be_instance_of Hash
        expect(pet.keys.sort).must_equal PET_FIELDS
      end
    end
    
    it "will respond with an empty array when there are no pets" do
      Pet.destroy_all
      
      get pets_path
      
      body = check_response(expected_type: Array, expected_status: :ok)
      expect(body).must_equal []
    end
  end
  
  describe "show" do
    let(:pet) {
      pets(:one)
    }
    
    it "responds with JSON, success, and a hash of pet data" do
      get pet_path(pet.id)
      
      body = check_response(expected_type: Hash, expected_status: :ok)
      expect(body.keys.sort).must_equal PET_FIELDS
      expect(body["id"]).must_equal pet.id
      expect(body["age"]).must_equal pet.age
      expect(body["human"]).must_equal pet.human
      expect(body["name"]).must_equal pet.name
    end
    
    it "will respond with empty hash and not_found if the pet does not exist" do
      get pet_path(-1)
      
      body = check_response(expected_type: Hash, expected_status: :not_found)
      expect(body["ok"]).must_equal false
      expect(body.keys).must_include "errors"
    end
  end
  
  describe "create" do
    let(:pet_data) {
      {
        pet: {
          age: 13,
          name: 'Stinker',
          human: 'Grace'
        }
      }
    }
    
    it "can create a new pet" do
      expect {
        post pets_path, params: pet_data
      }.must_differ 'Pet.count', 1
      
      body = check_response(expected_type: Hash, expected_status: :created)
    end
    
    it "will respond with bad_request for invalid params" do
      pet_data[:pet][:age] = nil
      
      expect {
        post pets_path, params: pet_data
      }.wont_differ "Pet.count"
      
      body = check_response(expected_type: Hash, expected_status: :bad_request)
      expect(body["ok"]).must_equal false
      expect(body["errors"].keys).must_include "age"
    end
    
    describe "update" do
      let(:pet) {
        pets(:one)
      }
      
      let(:new_pet_data) {
        {
          pet: {
            age: 3,
            name: 'Peanut Sr.',
          }
        }
      }
      
      it "can update a pet with valid params" do
        expect {
          patch pet_path(pet.id), params: new_pet_data
        }.wont_differ "Pet.count"
        
        body = check_response(expected_type: Hash, expected_status: :ok)
        updated_pet = Pet.find_by(id: body["id"])
        expect(updated_pet).wont_be_nil
        expect(updated_pet.age).must_equal new_pet_data[:pet][:age]
        expect(updated_pet.name).must_equal new_pet_data[:pet][:name]
        expect(updated_pet.human).must_equal pet.human
      end
      
      it "won't update a pet with invalid params" do
        new_pet_data[:pet][:age] = nil
        
        expect {
          patch pet_path(pet.id), params: new_pet_data
        }.wont_differ "Pet.count"
        
        body = check_response(expected_type: Hash, expected_status: :bad_request)
        expect(body["ok"]).must_equal false
        expect(body["errors"].keys).must_include "age"
        
        updated_pet = Pet.find_by(id: pet.id)
        expect(updated_pet).wont_be_nil
        expect(updated_pet.age).must_equal pet.age
        expect(updated_pet.name).must_equal pet.name
        expect(updated_pet.human).must_equal pet.human
      end
      
      it "returns JSON and bad_request for an invalid pet id" do
        expect {
          patch pet_path(-1), params: new_pet_data
        }.wont_differ "Pet.count"
        
        body = check_response(expected_type: Hash, expected_status: :bad_request)
        expect(body["ok"]).must_equal false
        expect(body["errors"].keys).must_include "id"
      end
    end
  end
end
