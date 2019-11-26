extends Spatial

const DEFAULT_MAX_AMMO = 10

var respawn_timer = Utils.dieRoll("2d5")
var zombiescene
var zombie_scene
var zombie_inst
var level = 1
var l = 0
#-----------------------------------------------------------
func _ready() :
  get_tree().paused = false
  _loadArena()

func _physics_process(delta):
 
  if level >2:
    if respawn_timer > 0:
        respawn_timer -= delta
  
    if respawn_timer <= 0:
      zspawn()
            
func _loadArena() :
  level = get_node('HUD Layer')._getLevel()
  _clearArena()

  var levelData = _getLevelData( level )
  print (level)

  var w = levelData.get( 'arenaSize', null )
  if w != null :
    _addWall( "res://Assets/Wall/Wall.tscn" , w )
    get_node( 'HUD Layer' )._resetAmmo( levelData.get( 'maxAmmo', DEFAULT_MAX_AMMO ) )
    
  var ammo = levelData.get( 'AMMO', null )
  if ammo != null :
    _addAmmo( ammo.get( 'tscn', null ), ammo.get( 'instances', [] ) )

  var zombies = levelData.get( 'ZOMBIES', null )
  if zombies != null :
    var instances = zombies.get( 'instances', [] )
    #var n = len( instances )
    _addZombies( zombies.get( 'tscn', null ), instances ,0)

  var obstacles = levelData.get( 'OBSTACLES', null )
  if obstacles != null :
    _addObstacles( obstacles.get( 'tscn', null ), obstacles.get( 'instances', [] ) )
  
  var healthpack = levelData.get( 'HEALTH', null )
  if healthpack != null :
    _addhealthpack( healthpack.get( 'tscn', null ), healthpack.get( 'instances', [] ) )
    
  if level > 2 :
    var platform = levelData.get( 'PLATFORM', null )
    if platform != null :
      if zombies != null :
        zombie_scene = zombies.get( 'tscn', null )
        zombie_inst = zombies.get( 'instances', [] )
        _addPlatform( platform.get( 'tscn', null ), platform.get( 'instances', [] )) 
    
  get_node( 'Player' )._ready()

#-----------------------------------------------------------
func _input( __ ) :    # Not using event so don't name it.
  if Input.is_action_just_pressed( 'maximize' ) :
    OS.window_fullscreen = not OS.window_fullscreen

#----------------------------------------------------------- 
func _addhealthpack  ( model, instances):
  var inst
  var index = 0

  if model == null :
    print( 'There were %d hp but no model?' % len( instances ) )
    return

  var hpscene = load( model )
  
  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( "1d6" )

    inst = hpscene.instance()
    inst.name = 'healthkit-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setQuantity( hp )
    print( '%s at %s, %d hp' % [ inst.name, str( pos ), hp ] )
    get_node( '.' ).add_child( inst )
  
func _addPlatform ( model, instances) :
  
  if model == null :
    print( 'There were %d ammo but no model?' % len( instances ) )
    return

  var inst
  var platScene = load( model )

  for instInfo in instances :

    var pos = instInfo[ 0 ]
    inst = platScene.instance()
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    print("Platform built")
    get_node( '.' ).add_child( inst )


func zspawn():
  #var len_inst = len(zombie_inst)
  respawn_timer = Utils.dieRoll("2d5") 
#  _loadArena() 
  level = get_node('HUD Layer')._getLevel()
  var levelData = _getLevelData( level )
  var zombies = levelData.get( 'ZOMBIES', null )
  if zombies != null :
    var instances = zombies.get( 'instances', [] )
    var n = len( instances )
    _addZombies( zombies.get( 'tscn', null ), instances ,n)
    get_node( 'Player' )._ready()

#-----------------------------------------------------------
func _addAmmo( model, instances ) :
  var inst
  var index = 0

  if model == null :
    print( 'There were %d ammo but no model?' % len( instances ) )
    return

  var ammoScene = load( model )
  
  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var amount  = Utils.dieRoll( instInfo[ 1 ] )

    inst = ammoScene.instance()
    inst.name = 'Ammo-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setQuantity( amount )
    print( '%s at %s, %d rounds.' % [ inst.name, str( pos ), amount ] )

    get_node( '.' ).add_child( inst )

func _addWall( model, instances ):
  if model == null:
    print( 'There is no model for Walls defined' )
    return
    
  var fmodel = load ( "res://Assets/Floor/Floor.tscn" )

  var wallScene = load( model )
  var inst 

  inst = fmodel.instance()
  inst.scale = Vector3(instances[0], 1, instances[1])
  inst.translation = Vector3(0, -0.1, 0)
  get_node( '.' ).add_child( inst )

  inst = wallScene.instance()
  inst.translation = Vector3( instances[0]/2, 1.5, 0 )
  inst.scale = Vector3( 0.5, 3, instances[1]/2 )
  get_node( '.' ).add_child( inst )

  inst = wallScene.instance()
  inst.translation = Vector3( -instances[0]/2, 1.5, 0 )
  inst.scale = Vector3( 0.5, 3, instances[1]/2 )
  get_node( '.' ).add_child( inst )
  
  inst = wallScene.instance()
  inst.translation = Vector3( 0, 1.5, instances[1]/2 )
  inst.scale = Vector3( instances[0]/2, 3, 0.5 )
  get_node( '.' ).add_child( inst )

  inst = wallScene.instance()
  inst.translation = Vector3( 0, 1.5, -instances[1]/2 )
  inst.scale = Vector3( instances[0]/2, 3, 0.5 )
  get_node( '.' ).add_child( inst )
    
#-----------------------------------------------------------
func _addObstacles( model, instances ) :
  var inst
  var index = 0

  if model == null :
    print( 'There were %d obstacles but no model?' % len( instances ) )
    return

  var obstacleScene = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]

    inst = obstacleScene.instance()
    inst.name = 'Obstacle-%02d' % index
    inst.translation = Vector3( pos[0], pos[1]+1, pos[2] )
    print( '%s at %s added.' % [ inst.name, str( pos ) ] )

    get_node( '.' ).add_child( inst )

#-----------------------------------------------------------
func _addZombies( model, instances,len_inst = 0 ) :
  var inst
  var index = 0
#  var zombieScene
  if len_inst == 0:
    l = len(instances)
    zombiescene = load( model )
    print(zombiescene)
  else:
    l += len_inst
    print(zombiescene)
  if model == null :
    print( 'There were %d zombie but no model?' % l )
    return

  get_node( 'HUD Layer' )._resetOpponents( l )
  
  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( "1d5" )

    inst = zombiescene.instance()
    inst.name = 'Zombie-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setHealth( hp )
    print( '%s at %s, %d hp' % [ inst.name, str( pos ), hp ] )
    
    get_node( '.' ).add_child( inst )

  
#-----------------------------------------------------------
func _getLevelData( levelNumber ) :
  var levelData = {}

  var fName = 'res://Levels/Level-%02d.json' % levelNumber

  var file = File.new()
  if file.file_exists( fName ) :
    file.open( fName, file.READ )
    var text_data = file.get_as_text()
    var result_json = JSON.parse( text_data )

    if result_json.error == OK:  # If parse OK
      levelData = result_json.result

    else :
      print( 'Error        : ', result_json.error)
      print( 'Error Line   : ', result_json.error_line)
      print( 'Error String : ', result_json.error_string)

  else :
    print( 'Level %d config file did not exist.' % levelNumber )

  return levelData

#-----------------------------------------------------------
func _clearArena():
  var d = ['Player Audio', 'Player', 'Zombie Audio', 'HUD Layer', 'Message Layer']
  var main = get_tree().get_root().get_node("World")
  
  for c in main.get_children():
    if not c.name in d:
      main.remove_child(c)
  
  main.get_node("Player").translation = Vector3(0, 0, 0)

func _checkFile( levelNumber ) :
  var fName = 'res://Levels/Level-%02d.json' % levelNumber

  var file = File.new()
  if file.file_exists( fName ) :
    return true
  else:
    return false

func _updateLevel():
  var currentLevel = $'HUD Layer'._getLevel() + 1
  
  $'HUD Layer'._setLevel(currentLevel)
  
  var timeStr = $'HUD Layer'.getTimeStr()
  if _checkFile(currentLevel) == false:
    $'HUD Layer'._setLevel(1)
    $'Message Layer/Message'.activate( 'Player Wins!\n%s' % timeStr )
  else:
    print("Move to next level")
    _loadArena()


