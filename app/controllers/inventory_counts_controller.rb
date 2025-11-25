
# author: Boris Barroso
# email: boriscyber@gmail.com

# Reconcile discrepancies --
# If there are any discrepancies between the physical inventory count and the inventory records,
# investigate and resolve them.
# See https://katanamrp.com/blog/inventory-count/

class InventoryCountsController < ApplicationController
  # PUT, PATCH /stocks/:id
  def update
    @stock = Stock.find(params[:id])

    if @stock.save_minimum(params[:minimum])
      render json: { success: true, id: params[:id], minimum: @stock.minimum }
    else
      render json: @stock.errors
    end
  end

end
