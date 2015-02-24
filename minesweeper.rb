# http://notes.vveleva.com/
require 'yaml'

class Game
  def initialize
    @board = Board.new
    @lost = false
  end

  def play
    puts "Welcome to Minesweeper!"
    puts "Type 'r' to reveal or 'f' to flag a spot"
    puts "followed by coordinates (row, column)."
    puts "Example: 'f 3,2' will flag coordinate [3,2]"
    puts "Type 'save' at any time to save your game."

    until over?
      display
      input = get_input
      update_tile(input)
    end

    if won?
      puts "You win!"
    elsif lost?
      puts "You lose!"
    end

    display
  end

  def get_input
    valid_input = /\A([r|f])\s([0-8]),([0-8])\z/
    user_choice = ''

    until user_choice.match(valid_input) || user_choice.downcase == 'save'
      print "Type input ('r 0,8'): "
      user_choice = gets.chomp
    end

    if user_choice.downcase == 'save'
      save
    else
      action, row, col = user_choice.scan(valid_input)[0]
      [action, row, col]
    end
  end

  def update_tile(input)
    action, row, col = input
    current_tile = @board.board[row.to_i][col.to_i]

    if current_tile.flagged? && action == 'r'
      return
    end

    if current_tile.bombed? && action == 'r'
      @board.reveal_all_bombs
      @lost = true
    else
      current_tile.set_action(action)
    end
  end

  def display
    puts render
  end

  def render
    new_str = "   "
    @board.size.times do |i|
      new_str << i.to_s
      new_str << "  "
    end

    new_str << "\n"

    @board.board.each_with_index do |row, idx|
      new_str << idx.to_s << "  "
      row.each_with_index do |col, idx2|
        new_str << col.inspect << "  "
      end
      new_str << "\n"
    end

    new_str
  end

  def over?
    won? || lost?
  end

  def lost?
    @lost
  end

  def won?
    correct_flags == @board.num_bombs && incorrect_flags == 0
  end

  def correct_flags
    flags = 0
    @board.board.each do |row|
      row.each do |col|
        flags += 1 if col.flagged? && col.has_bomb
      end
    end

    flags
  end

  def incorrect_flags
    flags = 0
    @board.board.each do |row|
      row.each do |col|
        flags +=1 if col.flagged? && !col.has_bomb
      end
    end

    flags
  end

  def save
    File.open("minesweeper.yml", "w") do |f|
      f.puts self.to_yaml
    end

    exit
  end

  def self.load
    YAML.load_file("minesweeper.yml")
  end

end

class Tile
  POSSIBLE_NEIGHBORS = [[0, 1], [0, -1], [1, 0], [1, -1],
                        [1, 1], [-1, 0], [-1, -1], [-1, 1]]

  attr_reader :position, :has_bomb
  attr_accessor :display

  def initialize(board, position, has_bomb)
    @board = board
    @position = position
    @has_bomb = has_bomb
    @flag = false
    @display = "*"
  end

  def reveal
    return if revealed?
    bomb_count = neighbor_bomb_count
    if bomb_count > 0 && !@flag
      @display = bomb_count.to_s
    else
      @display = "_" unless @flag
      neighbors.each do |neighbor|
        neighbor.reveal
      end
    end
  end

  def revealed?
    @display != "*"
  end

  # def display
  #   if revealed?
  #     if neighbor_bomb_count > 0
  #       neighbor_bomb_count
  #     else
  #       "_"
  #     end
  #   elsif flagged?
  #     "F"
  #   else
  #     "*"
  #   end
  # end

  def neighbors
    neighbors = []

    POSSIBLE_NEIGHBORS.each do |pos|
      row, col = [pos[0] + @position[0], pos[1] + @position[1]]
      neighbors << @board[row][col] if valid_neighbor?([row, col])
    end

    neighbors
  end

  def valid_neighbor?(position)
    row = position[0]
    col = position[1]
    boundary = @board.size

    row >= 0 && row < boundary && col >= 0 && col < boundary
  end

  def neighbor_bomb_count
    count = 0
    neighbors.each do |neighbor|
      count += 1 if neighbor.bombed?
    end

    count
  end

  def bombed?
    @has_bomb
  end

  def set_flag
    @flag = true
    @display = 'F'
  end

  def reset_flag
    @flag = false
    @display = '*'
  end
  #
  # def toggle_flag
  #   @flag = !@flag
  # end

  def set_action(action)
    if action == 'r'
      reveal
    else
      @flag ? reset_flag : set_flag
    end
  end

  def flagged?
    @flag
  end

  def inspect
    "#{@display}"
  end
end

class Board
  attr_reader :board, :size, :num_bombs

  def initialize(size=9, num_bombs=10)
    @num_bombs = num_bombs
    @size = size
    build_board(size, num_bombs)
  end

  def build_board(size, num_bombs)
    @board = Array.new(size) { Array.new(size) }
    bomb_pos = rand_bomb_positions
    @board.each_with_index do |row, idx|
      row.each_with_index do |column, idx2|
        current_pos = [idx, idx2]
        set_bomb = (bomb_pos.include?(current_pos))
        @board[idx][idx2] = Tile.new(@board, current_pos, set_bomb)
      end
    end
  end

  def rand_bomb_positions
    bomb_pos = []
    until bomb_pos.count == @num_bombs
      index1 = rand(@size)
      index2 = rand(@size)
      position = [index1, index2]
      bomb_pos << position unless bomb_pos.include?(position)
    end

    bomb_pos
  end

  def reveal_all_bombs
    @board.each do |row|
      row.each do |tile|
        tile.display = "B" if tile.has_bomb
      end
    end
  end
end
