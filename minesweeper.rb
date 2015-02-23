class Game

  def initialize
    @board = Board.new
  end


end

class Tile
  attr_reader :display, :position, :has_bomb
  def initialize(board, position, has_bomb)
    @board = board
    @position = position
    @has_bomb = has_bomb
    @flag = false
    @display = "*"
  end

  def reveal
  end

  def revealed?
    @display != "*"
  end

  def neighbors
  end

  def neighbor_bomb_count
  end

  def bombed?
    @has_bomb
  end

  def flagged?
    @flag
  end

  def inspect
    "position: #{@position}, display: #{@display}, has bomb: #{@has_bomb}"
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
    p @board
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

class Player


end
