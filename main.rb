require 'rubygems'
require 'gosu'
require 'set'
require_relative 'ball'
require_relative 'line'


class Window < Gosu::Window

	def initialize(width, height)
		super(width, height, false)
		self.caption = 'Divide0'
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		@bg_color = Gosu::Color.new(50, 0, 0, 255)
		@line_color = Gosu::Color.new(7, 157, 208, 255)
		
		@random = Random.new
		@balls = Set.new
		@lines_expanding = Set.new
		@lines_expanded = Set.new
	end
	
	def line_contains_point?(line, x, y)
		if x == line.x1 && (y >= line.y1 && y <= line.y2)
				return true
		elsif y == line.y1 && (x >= line.x1 && x <= line.x2)
				return true
		end
		return false
	end

	def lines_contain_point?(lines, x, y)
		lines.each do |line|
			if line_contains_point?(line, x, y)
				return true
			end
		end
		return false
	end

	def get_rand_ball
		dX = @random.rand(1..6)
		dX *= dX % 2 == 0 ? 1 : -1
		
		dY = @random.rand(1..6)
		dY *= dY % 2 == 0 ? 1 : -1
		
		return Ball.new(@random.rand(0..$win_width), @random.rand(0..$win_height), dX, dY)
	end
	
	def update
		# Move balls
		@balls.each do |ball|
			ball.move
			ball.update(@balls)
		end

		@lines_expanding.each do |line|
			# Expand line and add to set of expanded lines if max size is reached
			if line.update(@lines_expanding, @lines_expanded)
				@lines_expanded << line
			end
			@lines_expanding -= @lines_expanded	# Removes expanded line from expanding set to prevent unneccesary updates

		puts "Expanding: " + @lines_expanding.size.to_s + " Expanded: " + @lines_expanded.size.to_s
		end
	end
	
	def draw
		draw_quad(0, 0, @bg_color, $win_width, 0, @bg_color,
			0, $win_height, @bg_color, $win_width, $win_height, @bg_color, 0)
		
		# Draw balls
		@balls.each do |ball|
			ball.draw
		end

		# Draw lines
		@lines_expanding.each do |line|
			line.draw
		end
		@lines_expanded.each do |line|
			line.draw
		end
		
		# Frame rate
		@font.draw(Gosu::fps(), 5, 5, 2, 1.0, 1.0, 0xffffffff)
	end
	
	def button_down(id)
		case id
		when Gosu::MsLeft
			if !lines_contain_point?(@lines_expanding, mouse_x, mouse_y) && 
				!lines_contain_point?(@lines_expanded, mouse_x, mouse_y)
					@lines_expanding << Line.new(mouse_x, mouse_y, false)
			end
		when Gosu::MsRight
			if !lines_contain_point?(@lines_expanding, mouse_x, mouse_y) && 
				!lines_contain_point?(@lines_expanded, mouse_x, mouse_y)
					@lines_expanding << Line.new(mouse_x, mouse_y, true)
			end
		when Gosu::KbR
			@balls << get_rand_ball
		when Gosu::KbEscape
			close
		end
	end
	
	def needs_cursor?	# Forces Gosu to paint cursor
		true
	end
	
end

$win_width = 500
$win_height = 500
$window = Window.new($win_width, $win_height)
$window.show