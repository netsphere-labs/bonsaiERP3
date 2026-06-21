
# exchange rates
class CurrXchgsController < ApplicationController
  before_action :set_curr_xchg, only: %i[ destroy ]

  # GET /curr_xchgs or /curr_xchgs.json
  def index
    today = Date.today
    @curr_list = []
    @days = []
    @matrix = {}
    CurrXchg.where('date BETWEEN ? AND ?', today - 60, today).order("date DESC").each do |r|
      @curr_list.index(r.curr_code) || @curr_list.push(r.curr_code)
      @days.index(r.date) || @days.push(r.date) 

      @matrix[r.date] ||= {}
      @matrix[r.date][r.curr_code] = r.rate
    end
  end

=begin
  # GET /curr_xchgs/1 or /curr_xchgs/1.json
  def show
  end

  # GET /curr_xchgs/new
  def new
    @curr_xchg = CurrXchg.new
  end

  # GET /curr_xchgs/1/edit
  def edit
  end

  # POST /curr_xchgs or /curr_xchgs.json
  def create
    @curr_xchg = CurrXchg.new(curr_xchg_params)

    respond_to do |format|
      if @curr_xchg.save
        format.html { redirect_to @curr_xchg, notice: "Curr xchg was successfully created." }
        format.json { render :show, status: :created, location: @curr_xchg }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @curr_xchg.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /curr_xchgs/1 or /curr_xchgs/1.json
  def update
    respond_to do |format|
      if @curr_xchg.update(curr_xchg_params)
        format.html { redirect_to @curr_xchg, notice: "Curr xchg was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @curr_xchg }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @curr_xchg.errors, status: :unprocessable_entity }
      end
    end
  end
=end
  
  # DELETE /curr_xchgs/1 or /curr_xchgs/1.json
  def destroy
    @curr_xchg.destroy!

    respond_to do |format|
      format.html { redirect_to curr_xchgs_path, notice: "Curr xchg was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_curr_xchg
      @curr_xchg = CurrXchg.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def curr_xchg_params
      params.fetch(:curr_xchg, {})
    end
end
