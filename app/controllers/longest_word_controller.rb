 class LongestWordController < ApplicationController
  def game
    @start_time = Time.now
    @grid = generate_grid(9).join(" ")
  end

 def score
    @entry = params[:entry]
    # grid = params[:grid].gsub(" ", "")
    start_time = params[:start_time]
    start_time = Time.parse(start_time)
    end_time = Time.now
    @result = run_game(@entry, grid, start_time, end_time)
  end


end



require 'open-uri'
require 'json'

def generate_grid(grid_size)
  Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
end


def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - start_time }
  result[:translation] = get_translation(attempt)
  result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid, result[:time])
  result
end




def included?(guess, grid)
  guess = guess.chars
  guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
end

def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end



def score_and_message(attempt, translation, grid, time)
  if included?(attempt.upcase, grid)
    if translation
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not an english word"]
    end
  else
    [0, "not in the grid"]
  end
end

def get_translation(word)
  api_key = "5236bc4b-4088-4263-8df7-3faa39e16027"
  response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
  json = JSON.parse(response.read.to_s)
  if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
    return json['outputs'][0]['output']
  else
    return nil
  end
end
