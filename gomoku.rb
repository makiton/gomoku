module Gomoku
  class Board
    attr_reader :current_turn

    BOARD_SIZE = 19
    CONDITION_FOR_WIN = 5
    HEADER_FORMAT = "%2d"
    CELL_FORMAT = " %s"
    VECTORS = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1]
    ]
    BLACK = 0
    WHITE = 1

    def initialize
      @board = BOARD_SIZE.times.map { BOARD_SIZE.times.map { Gomoku::Cell.new } }
      @current_turn = BLACK
    end

    def run
      loop do
        render
        begin
          x, y = wait_for_input
          put_stone(x, y)
        rescue
          puts "You can't put stone there."
          retry
        end
        break if judge
        change_turn
      end
      render
      puts "winner: #{turn_string}"
    end

    def clean_judge
      @dead_stones = []
    end

    def judge
      clean_judge
      @board.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          next if cell.empty?

          cur_value = cell.value
          VECTORS.each do |dx, dy|
            cnt = 1
            cur_x = x
            cur_y = y
            loop do
              cur_x += dx
              cur_y += dy
              break if @board[cur_y][cur_x].value != cur_value
              cnt += 1
            end
            return true if cnt >= CONDITION_FOR_WIN
          end
        end
      end
      false
    end

    def wait_for_input
      print "#{turn_string} input(x, y): "
      gets.split(",").map { |v| v.to_i - 1 }
    end

    def render
      print "  "
      BOARD_SIZE.times.each do |x|
        print HEADER_FORMAT % (x + 1)
      end
      print "\n"
      y = 0
      @board.each do |row|
        y += 1
        print HEADER_FORMAT % y
        row.each do |cell|
          print CELL_FORMAT % cell.to_s
        end
        print "\n"
      end
      print "\n"
    end

    def put_stone(x, y)
      raise "cannot put" unless x.between?(0, BOARD_SIZE - 1) && y.between?(0, BOARD_SIZE - 1)
      
      @board[y][x].value = (black_turn? ? Cell::BLACK : Cell::WHITE)
    end

    def black_turn?
      current_turn == BLACK
    end

    def white_turn?
      current_turn == WHITE
    end

    def turn_string
      black_turn? ? "black" : "white"
    end

    def change_turn
      @current_turn = black_turn? ? WHITE : BLACK
    end
  end

  class Cell
    attr_reader :value

    BLACK = 'x'
    WHITE = 'o'
    EMPTY = ' '

    def initialize
      @value = EMPTY
    end

    def value=(val)
      raise 'cannot put' unless empty?

      @value = val
    end

    def to_s
      @value
    end

    def empty?
      @value == EMPTY
    end
  end
end

Gomoku::Board.new.run
