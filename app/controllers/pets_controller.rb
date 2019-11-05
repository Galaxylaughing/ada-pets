class PetsController < ApplicationController
  def index
    pets = Pet.all.as_json(only: [:id, :name, :age, :human])
    render json: pets, status: :ok
  end
  
  def show
    pet = Pet.find_by(id: params[:id])
    if pet
      render json: pet, status: :ok
    else
      render json: {}, status: :not_found
    end
  end
  
  
  private
  
  def pet_params
    params.require(:pet).permit(:name, :age, :human)
  end
end
