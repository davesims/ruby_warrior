class Player

  def play_turn(warrior)
    init_turn(warrior)
    if enemies_near? && !captives_near? && !warrior.taking_damage?
      warrior.shoot!
    elsif next_space.wall?
      if warrior.healthy?
        warrior.change_direction 
        warrior.march!
      else
        warrior.rest!
      end
    elsif next_space.empty?
      if warrior.taking_damage? 
        warrior.change_direction if !warrior.can_defeat_archer?
        warrior.march!
      elsif warrior.healthy? || !enemies_near?
        warrior.march!
      else
        warrior.rest!
      end
    elsif next_space.enemy?
      if warrior.backward?
        warrior.pivot!
      else
        warrior.assault!
      end
    elsif next_space.captive?
      warrior.save!
    end
  end
  
  def enemies_near?
    surroundings.any?{|space| space.enemy? }
  end
  
  def captives_near?
    surroundings.any?{|space| space.captive? }
  end

  attr_reader :next_space, :surroundings

  def init_turn(warrior)
    @surroundings = warrior.look
    @next_space = warrior.search
    warrior.taking_damage = @last_health && warrior.health < @last_health
    @last_health = warrior.health
  end

  class RubyWarrior::Turn
    attr_accessor :taking_damage, :direction
    def taking_damage?; taking_damage; end
    
    DIRECTION_METHOD_ALIASES = {:walk! => :march!, :feel => :search, :rescue! => :save!, :attack! => :assault!}
    MINIMUM_HEALTH_TO_DEFEAT_ARCHER = 11
    HEALTHY = 20
    
    DIRECTION_METHOD_ALIASES.each do |action, aliased|
      define_method(aliased) do
        send(action, direction)
      end
    end
    
    def healthy?
      health == HEALTHY
    end
    
    def can_defeat_archer?
      health > MINIMUM_HEALTH_TO_DEFEAT_ARCHER
    end
  
    class_variable_set(:@@orientation, [:forward, :backward])
    
    def self.orientation
      class_variable_get(:@@orientation)
    end
    
    def direction
      RubyWarrior::Turn.orientation[0]
    end
    
    def change_direction
      RubyWarrior::Turn.orientation.reverse!
    end
    
    def backward?
      direction == :backward
    end
  end
end
