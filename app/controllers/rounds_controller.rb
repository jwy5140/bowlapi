class RoundsController < ApplicationController
  
  def create
    @round = Round.create(params.permit[:game_id, :player_id, :round_num], total: 0)
    @player = Player.find(params[:player_id])
    if @round.valid?
      render json: {success: "#{@player.name}, you're up!"}, status: :ok
    else
      render json: {error: "Unable to start round - please reset"}, status: :bad_request
  end

  def first_attempt
    @round = Round.find(params[:id])
    @player = Player.find(params[:player_id])
    @round.first_roll = params[:pins_hit]

    if params[:round_num] > 1
      @prev = Round.find_by(game_id: params[:game_id], round_num: params[:round_num])
    end

    if params[:pins_hit] === 10
      @round.strike = true
    end

    @player.score = @player.score + params[:pins_hit]    
    add_total(params[:pins_hit])

    if @prev.strike === true || @prev.spare === true
      add_bonus(:pins_hit)
    end
  end

  def second_attempt
    @round = Round.find(params[:id])
    @round.second_roll = params[:pins_hit]

    if @round.first_roll + @round.second_roll === 10 
      @round.spare = true
    end
    
    @player.score = @player.score + params[:pins_hit]    
    add_total(params[:pins_hit])

    if @prev.strike === true
      redirect_to "game/#{@round.game_id}/#{@player.id}/round/#{@round.id-1}/bonus/#{params[:pins_hit]}"
    end
  end

  def add_bonus(points)
    @round = Round.find_by(game_id: params[:game_id], round_num: params[:round_num]-1)
    @player = Player.find(params[:player_id])

    @player.score = @player.score + params[:pins_hit]    
  end

  def add_total(points)
    @round = Round.find(params[:id])
    @round.total = @round.total + points
  end

  # private

  # def r_params
  #   params.require(:round).permit(:game_id, :player_id, :pins_hit, :first_roll, :second_roll, :strike, :spare, :total)
  # end

end
