extends Spatial

const DEFAULT_MAX_AMMO = 10
var level = 1
var respawn_timer = Utils.dieRoll("2d5")
var spawn_portal = false
var zombieScene
var zombie_scene
var zombie_inst
var l #zombie instance length 
#-----------------------------------------------------------

func _physics_process(delta):
#  print("sp out",spawn_portal)
  if level >2:
    if respawn_timer > 0:
        respawn_timer -= delta
    
#    print("sp",spawn_portal)
    if respawn_timer <= 0:
      spawn_portal = get_node( 'Player' ).set_spawn_status()
      if spawn_portal == false:
        zspawn()
#-----------------------------------------------------------
func _ready() :
  get_tree().paused = false

  level = UserData.CURRENT_LEVEL
  print(level)
  var levelData = _getLevelData( )
  
  var arena = levelData.get('arena', null )
  if arena != null :
    _addArena( arena.get('floorModel', null ), arena.get('wallModel', null ), arena.get('length', null), arena.get('breadth', null))

  var ammo = levelData.get( 'AMMO', null )
  if ammo != null :
    _addAmmo( ammo.get( 'tscn', null ), ammo.get( 'instances', [] ) )
	
  var obstacles = levelData.get( 'OBSTACLES', null )
  if obstacles != null :
    _addObstacles( obstacles.get( 'tscn', null ), obstacles.get( 'instances', [] ) )

  var zombies = levelData.get( 'ZOMBIES', null )
  if zombies != null :
    _addZombies( zombies.get( 'tscn', null ), zombies.get( 'instances', [] ) )
	
  #var exploding_zombies = levelData.get( 'EXPLODING_ZOMBIES', null )
  #if exploding_zombies != null :
    #_addExplodingZombies( exploding_zombies.get( 'tscn', null ), exploding_zombies.get( 'instances', [] ) )
  
  var healthKits = levelData.get( 'HEALTH_KITS', null )
  if healthKits != null :
    _addHealthKits( healthKits.get( 'tscn', null ), healthKits.get( 'instances', [] ) )
  
  var hp_PowerUp = levelData.get( 'HEALTH_POWERUP', null )
  if hp_PowerUp != null :
    _addHealthPowerUps( hp_PowerUp.get( 'tscn', null ), hp_PowerUp.get( 'instances', [] ) )
    
  var dmg_PowerUp = levelData.get( 'DAMAGE_POWERUP', null )
  if dmg_PowerUp != null :
    _addDmgPowerUps( dmg_PowerUp.get( 'tscn', null ), dmg_PowerUp.get( 'instances', [] ) )
   
  var teleport = levelData.get( 'TELEPORT', null )
  if teleport != null :
    _addTeleportPod( teleport.get( 'tscn', null ), teleport.get( 'instances', [] ) )
 
  var keyport = levelData.get( 'KEY', null )
  if keyport != null :
    _addKey( keyport.get( 'tscn', null ), keyport.get( 'instances', [] ) )
 
  
  if level > 2 :
    var platform = levelData.get( 'PLATFORM', null )
    if platform != null :
      if zombies != null :
        zombie_scene = zombies.get( 'tscn', null )
        zombie_inst = platform.get( 'instances', [] )
        _addPlatform( platform.get( 'tscn', null ), platform.get( 'instances', [] )) 

  get_node( 'HUD Layer' )._resetAmmo( levelData.get( 'maxAmmo', DEFAULT_MAX_AMMO ) )
  get_node( 'HUD Layer' )._resetHealth( levelData.get( 'maxHealth', DEFAULT_MAX_AMMO ) )
  get_node( 'Player').set_key_status()

#-----------------------------------------------------------
func _input( __ ) :    # Not using event so don't name it.
  if Input.is_action_just_pressed( 'maximize' ) :
    OS.window_fullscreen = not OS.window_fullscreen

#-----------------------------------------------------------
func _addArena( floorModel, wallModel, length, breadth ):
  var inst
  var floorScene = load( floorModel )
  var yTranslation = -1.3
  var floorLoopStep = 2

  for i in range( (-length/2), (length/2), floorLoopStep) :
    for j in range( (-breadth/2), (breadth/2), floorLoopStep) :
      inst = floorScene.instance()
      inst.translation = Vector3( i, yTranslation, j )
      get_node( '.' ).add_child( inst )
  
  var wallScene = load( wallModel )
  var wallLength = 15
  
  var lengthScale = Utils.get_aabb( length, wallLength ) 
  var i = -length / 2
  while( i <= length / 2 ):
    inst = wallScene.instance()
    inst.translation = Vector3( breadth/2, 0, i )
    inst.scale = Vector3( lengthScale, 1, 1 )
    get_node( '.' ).add_child( inst )

    inst = wallScene.instance()
    inst.translation = Vector3( -breadth/2, 0, i )
    inst.scale = Vector3( lengthScale, 1, 1 )
    get_node( '.' ).add_child( inst )
    i = i + lengthScale*wallLength

  var breadthScale = Utils.get_aabb( breadth, wallLength ) 
  i = -breadth / 2
  while( i <= breadth / 2 ):
    inst = wallScene.instance()
    inst.translation = Vector3( i, 0, length/2 )
    inst.scale = Vector3( breadthScale, 1, 1 )
    inst.rotation_degrees = Vector3( 0, 90, 0 )
    get_node( '.' ).add_child( inst )

    inst = wallScene.instance()
    inst.translation = Vector3( i, 0, -length/2 )
    inst.scale = Vector3( breadthScale, 1, 1 )
    inst.rotation_degrees = Vector3( 0, 90, 0 )
    get_node( '.' ).add_child( inst )
    i = i + breadthScale*wallLength

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

#-----------------------------------------------------------
func _addHealthKits( model, instances ) :
  var inst
  var index = 0

  if model == null :
    print( 'There were %d health kits but no model?' % len( instances ) )
    return

  var healthKitScene = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var amount  = Utils.dieRoll( instInfo[ 1 ] )

    inst = healthKitScene.instance()
    inst.name = 'Health-Kit-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setQuantity( amount )
    print( '%s at %s, %d rounds.' % [ inst.name, str( pos ), amount ] )

    get_node( '.' ).add_child( inst )

#-----------------------------------------------------------
func _addObstacles( model, instances ) :
  var inst
  var index = 0
  var yTranslation = -1.4

  if model == null :
    print( 'There were %d obstacles but no model?' % len( instances ) )
    return

  var obstacleScene = load( model )
  print( model )
  print( obstacleScene ) 
  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( instInfo[ 1 ] )

    inst = obstacleScene.instance()
    inst.name = 'Obstacle-%02d' % index
    inst.translation = Vector3( pos[0], yTranslation, pos[2] )
#    inst.set_Health( hp )
    print( '%s at %s, %d hit points.' % [ inst.name, str( pos ), hp ] )

    get_node( '.' ).add_child( inst )

#-----------------------------------------------------------
func _addHealthPowerUps(model, instances):
  var inst
  var index = 0

  if model == null :
    print( 'There were %d dmg powerup but no model?' % len( instances ) )
    return

  var damage = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    inst = damage.instance()
    inst.setQuantity( 1.5 )
    inst.name = 'health-powerup-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    print( '%s at %s 15 hp' % [ inst.name, str( pos ) ] )
    get_node( '.' ).add_child( inst )
  
#----------------------------------------------------------
func _addDmgPowerUps(model, instances):
  var inst
  var index = 0

  if model == null :
    print( 'There were %d health power but no model?' % len( instances ) )
    return

  var healthpower = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
#    var amount  = Utils.dieRoll( instInfo[ 1 ] )

    inst = healthpower.instance()
    inst.name = 'Health-Powerup-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    
    print( '%s at %s.' % [ inst.name, str( pos ) ] )
    get_node( '.' ).add_child( inst )
    
#-----------------------------------------------------------
func _addExplodingZombies(model,instances):
  var inst
  var index = 0

  if model == null :
    print( 'There were %d explo_zombie but no model?' % len( instances ) )
    return

  var zombieScene = load( model )

  get_node( 'HUD Layer' )._resetOpponents( len( instances ) )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( instInfo[ 1 ] )

    inst = zombieScene.instance()
    inst.name = 'Exploding Zombie-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setHealth( hp )
    print( '%s at %s, %d hp' % [ inst.name, str( pos ), hp ] )

    get_node( '.' ).add_child( inst )
  
#-------------------------------------------------------------
func _addZombies( model, instances, len_inst = 0 ) :
  var inst
  var index = 0
    
  if len_inst == 0:
      l = len(instances)
      zombieScene = load( model )
#      print(zombieScene)
  else:
      l += len_inst
#      print(zombieScene)
  
  if model == null :
    print( 'There were %d zombie but no model?' % len( instances ) )
    return

#  zombieScene = load( model )

  get_node( 'HUD Layer' )._resetOpponents( l )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( instInfo[ 1 ] )

    inst = zombieScene.instance()
    inst.name = 'Zombie-%02d' % index
    inst.translation = Vector3( pos[0], pos[1], pos[2] )
    inst.setHealth( hp )
    print( '%s at %s, %d hp' % [ inst.name, str( pos ), hp ] )

    get_node( '.' ).add_child( inst )
#-----------------------------------------------------------
func _addTeleportPod(model,instances):
  var inst
  var index = 0
  var yTranslation = -1.4

  if model == null :
    print( 'There were %d obstacles but no model?' % len( instances ) )
    return

  var teleScene = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( instInfo[ 1 ] )
    
    inst = teleScene.instance()
    inst.name = 'teleScene-%02d' % index
    inst.translation = Vector3( pos[0], yTranslation, pos[2] )
#    inst.set_Health( hp )
    print( '%s at %s, %d hit points.' % [ inst.name, str( pos ), hp ] )

    get_node( '.' ).add_child( inst )

#------------------------------------------------------------
func _addKey(model,instances):
  var inst
  var index = 0
  var yTranslation = -1.4

  if model == null :
    print( 'There were %d obstacles but no model?' % len( instances ) )
    return

  var KeyScene = load( model )

  for instInfo in instances :
    index += 1

    var pos = instInfo[ 0 ]
    var hp  = Utils.dieRoll( instInfo[ 1 ] )
    
    inst = KeyScene.instance()
    inst.name = 'KeyScene-%02d' % index
    inst.translation = Vector3( pos[0], yTranslation, pos[2] )
#    inst.set_Health( hp )
    print( '%s at %s, %d hit points.' % [ inst.name, str( pos ), hp ] )

    get_node( '.' ).add_child( inst )

#-----------------------------------------------------------
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
#-------------------------------------------------------------
func zspawn():

  respawn_timer = Utils.dieRoll("2d5") 
  var n = len( zombie_inst )
  _addZombies( zombie_scene, zombie_inst ,n)
  get_node( 'Player' )._ready()
#-----------------------------------------------------------
func _getLevelData( ) :
	
  var user_data = UserData._getUserData()
  var levelNumber = user_data.get( 'currentLevel', null )
  var levelData = { }
  if levelNumber == -1:
     return levelData

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
