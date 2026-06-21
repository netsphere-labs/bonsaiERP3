
=begin
ある product を構成する BoM は、テンプレート BoM と、受注ごとに生成されるそれの 2 種
類がある
  -> bom_type 
=end

class BomStructuresController < ApplicationController
  before_action :set_item
  before_action :set_bom_structure, only: %i[ show edit update destroy ]

  # GET /bom_structures or /bom_structures.json
  def index
    @bom_structures = BomStructure.all
  end

  # GET /bom_structures/1 or /bom_structures/1.json
  def show
  end

  # GET /bom_structures/new
  def new
    @bom_structure = BomStructure.new
  end

  # GET /bom_structures/1/edit
  def edit
  end

  # POST /bom_structures or /bom_structures.json
  def create
    @bom_structure = BomStructure.new(bom_structure_params)

    respond_to do |format|
      if @bom_structure.save
        format.html { redirect_to @bom_structure, notice: "Bom structure was successfully created." }
        format.json { render :show, status: :created, location: @bom_structure }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bom_structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bom_structures/1 or /bom_structures/1.json
  def update
    respond_to do |format|
      if @bom_structure.update(bom_structure_params)
        format.html { redirect_to @bom_structure, notice: "Bom structure was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @bom_structure }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bom_structure.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bom_structures/1 or /bom_structures/1.json
  def destroy
    @bom_structure.destroy!

    respond_to do |format|
      format.html { redirect_to bom_structures_path, notice: "Bom structure was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  
private

  # before_action
  def set_item
    @item = Item.find(params[:item_id])
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_bom_structure
    @bom_structure = BomStructure.where(item_id: @item.id, id: params[:id]).take
    raise ActiveRecord::RecordNotFound if !@bom_structure
  end

    # Only allow a list of trusted parameters through.
    def bom_structure_params
      params.fetch(:bom_structure, {})
    end
end
