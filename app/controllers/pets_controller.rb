class PetsController < ApplicationController
  KEYS = [:id, :name, :age, :human]
  
  def index
    pets = Pet.all.as_json(only: KEYS)
    render json: pets, status: :ok
  end
  
  def show
    pet = Pet.find_by(id: params[:id]).as_json(only: KEYS)
    if pet
      render json: pet, status: :ok
      return
    else
      render json: { ok: false, errors: ["Not Found"] }, status: :not_found
      return
    end
  end
  
  def create
    pet = Pet.new(pet_params)
    
    if pet.save
      render json: pet.as_json(only: [:id]), status: :created
      return
    else
      render json: { ok: false, errors: pet.errors.messages}, status: :bad_request
      return
    end
  end
  
  def update
    pet = Pet.find_by(id: params[:id])
    
    if pet
      if pet.update(pet_params)
        render json: pet.as_json(only: [:id]), status: :ok
        return
      else
        render json: { ok: false, errors: pet.errors.messages }, status: :bad_request
        return
      end
    else
      render json: { ok: false, errors: {id: "no pet found with id #{params[:id]}"} }, status: :bad_request
      return
    end
  end
  
  private
  
  def pet_params
    params.require(:pet).permit(:name, :age, :human)
  end
end
