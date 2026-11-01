
# 部門、品目などの "軸" を表す
class TagGroupsController < ApplicationController
  before_action :set_tag_group,
                only: %i[show edit update destroy ]

  # GET /tag_groups
  def index
    @pagy, @tag_groups = pagy(:offset, TagGroup.order(:name) )
  end

  
  # GET /tag_groups/new
  def new
    @tag_group = TagGroup.new
  end

  
  # POST /tag_groups
  def create
    @tag_group = TagGroup.new(tag_group_params)

    begin
      ActiveRecord::Base.transaction do
        @tag_group.save!
      end
    rescue ActiveRecord::RecordInvalid => e
      render :new, status: :unprocessable_entity
      return
    end

    redirect_to @tag_group
  end


  def show
  end

  
  # GET /tag_groups/:id/edit
  def edit
    #@tag_group = TagGroup.find(params[:id])
  end

  # PATCH, PUT /tag_groups/:id
  def update
    #tag_group = TagGroup.find(params[:id])

    if tag_group.update(tag_group_params)
      render json: tag_group
    else
      render json: { errors: tag_group.errors }, status: 409
    end
  end

  def destroy
  end
  
private

  # before_action()
  def set_tag_group
    @tag_group = TagGroup.find params[:id]
  end

  def tag_group_params
    params.require(:tag_group)
        .permit(:name, :bgcolor, tag_ids: [])
  end
end
