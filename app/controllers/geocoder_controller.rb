class GeocoderController < ApplicationController
  before_action :set_geocoder

  def addresses
    address=address_params[:address]
    geoloc=@geocoder.geocode(address)
    geocode_response geoloc
  end

  def positions
    lng=position_params[:lng].to_f
    lat=position_params[:lat].to_f
    geoloc=@geocoder.reverse_geocode(Point.new(lng,lat))
    geocode_response geoloc
  end

  private
    def set_geocoder
      @geocoder=Geocoder.new
    end
    def address_params
      params.tap { |p| p.require(:address) }
    end
    def position_params
      params.tap { |p|
        p.require(:lng)
        p.require(:lat)
      }
    end
    def geocode_response geoloc
      if !geoloc
        full_message_error "failed to geocode position", :internal_server_error
      else
        expires_in 1.day, :public=>true
        render json: geoloc.to_hash, status: :ok
      end
    end
end
