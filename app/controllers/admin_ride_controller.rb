class AdminRideController < ApplicationController

  before_action :authenticate_user!
  layout 'administration'

  def new
    @ride = Ride.new
  end

  def show
    @ride = Ride.find(params[:id])
    @start_location = Location.find(@ride.start_location_id)
    @end_location = Location.find(@ride.end_location_id)
  end

  def index
    @rides = Ride.all
  end

  def create
    select_rider = Rider.find(ride_params[:rider_id])
    @token = select_rider.next_valid_token
    @token = select_rider.valid_tokens.create if @token.nil?

    # unless @token.nil?
      @start_location = Location.new(street: ride_params[:start_street],
                                     city: ride_params[:start_city],
                                     state: ride_params[:start_state],
                                     zip: ride_params[:start_zip])
      if !@start_location.save
        render 'new' and return
      end

      @end_location = Location.new(street: ride_params[:end_street],
                                   city: ride_params[:end_city],
                                   state: ride_params[:end_state],
                                   zip: ride_params[:end_zip])
      if !@end_location.save
        render 'new' and return
      end

      @ride = Ride.new(organization_id: current_user.organization_id,
                       rider_id: ride_params[:rider_id],
                       pick_up_time: ride_params[:pick_up_time],
                       start_location_id: @start_location.id,
                       end_location_id: @end_location.id,
                       reason: ride_params[:reason],
                       status: "requested")

      if @ride.save
        @token.ride_id = @ride.id
        @token.save
        flash[:notice] = "Ride created for #{select_rider.full_name}"
        redirect_to admin_ride_path(@ride)
      else
        render 'new'
      end
    # else
    #   flash[:notice] = "The rider does not have enough valid tokens to request this ride."
    #   redirect_to admin_ride_index_path
    # end
  end

  def edit
    @ride = Ride.find(params[:id])
  end

  def update
    @ride = Ride.find(params[:id])
    @start_location = @ride.start_location
    @end_location = @ride.end_location

    if !@start_location.update(
      street: ride_params[:start_street],
      city: ride_params[:start_city],
      state: ride_params[:start_state],
      zip: ride_params[:start_zip])
      flash.now[:alert] = @start_location.errors.full_messages.join(", ")
      render 'edit' and return
    end

    if !@end_location.update(
      street: ride_params[:end_street],
      city: ride_params[:end_city],
      state: ride_params[:end_state],
      zip: ride_params[:end_zip])
      flash.now[:alert] = @end_location.errors.full_messages.join(", ")
      render 'edit' and return
    end

    if @ride.update(
      organization_id: current_user.organization_id,
      rider_id: ride_params[:rider_id],
      pick_up_time: ride_params[:pick_up_time],
      reason: ride_params[:reason])
      flash.notice = "The ride information has been updated"
      redirect_to admin_ride_path(@ride)
    else
      render 'edit'
    end
  end

  def destroy
    @ride = Ride.find(params[:id])
    @ride.destroy
    redirect_to admin_ride_index_path
  end



  private

    def ride_params
      params.require(:ride).permit(:rider_id, :driver_id, :pick_up_time,
        :start_street, :start_city, :start_state, :start_zip,
        :end_street, :end_city, :end_state, :end_zip, :reason, :status)
    end
end


