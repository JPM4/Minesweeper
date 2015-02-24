# http://notes.vveleva.com/

class Game

  def initialize
    @board = Board.new
  end

  def play
    puts "Welcome to Minesweeper!"
    puts "Type 'r' to reveal or 'f' to flag a spot"
    puts "followed by coordinates (row, column)."
    puts "Example: 'f 3,2' will flag coordinate [3,2]"

    until over?
      display
      input = get_input
      update_tile(input)
    end

  end

  def get_input
    valid_input = /\A([r|f])\s([0-8]),([0-8])\z/
    user_choice = ''

    until user_choice.match(valid_input)
      puts "Type input ('r 0,8'):"
      user_choice = gets.chomp
    end

    action, row, col = user_choice.scan(valid_input)[0]

    [action, row, col]
  end

  def update_tile(input)
    action, row, col = input
    current_tile = @board.board[row.to_i][col.to_i]
    p current_tile
    if current_tile.flagged? && action == 'r'
      return
    end

    current_tile.set_action(action)

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
    false
  end

  def won?
    false
  end

end

class Tile
  POSSIBLE_NEIGHBORS = [[0,1],[0,-1],[1,0],[1,-1],[1,1],[-1,0],[-1,-1],[-1,1]]

  attr_reader :display, :position, :has_bomb

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

  def set_action(action)
    if action == 'r'
      raise "You lost!" if bombed?
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
  attr_reader :board, :size

  def initialize(size=9, num_bombs=12)
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
        set_bomb = (bomb_pos.include?(current_pos) ? true : false)
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


end
