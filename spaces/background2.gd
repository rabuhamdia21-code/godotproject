
extends Node2D

# قيم الزيادة في السطوع أثناء اللعب
const PARTIAL_BRIGHTNESS_STEP: float = 0.05 
# السطوع الكامل (النهار)
const DAY_BRIGHTNESS: float = 1.0 
# مدة التحول الناعم للنهار
const DAY_TRANSITION_TIME: float = 2.0 

# متغيرات التتبع
var total_lamps: int = 0
var collected_lamps: int = 0
var total_enemies: int = 0
var killed_enemies: int = 0
var game_finished: bool = false

@onready var canvas_modulate: CanvasModulate = $CanvasModulate 
# تأكدي من مسار العقد الحاوية
@onready var lamps_container = $Lamps 
@onready var enemies_container = $Enemies 

func _ready():
	# 1. حساب الإجمالي
	if lamps_container:
		total_lamps = lamps_container.get_child_count()
	if enemies_container:
		total_enemies = enemies_container.get_child_count()
		
	print("Total Lamps: ", total_lamps, " | Total Enemies: ", total_enemies)

	# 2. ربط الإشارات من كل المصابيح
	if lamps_container:
		for lamp in lamps_container.get_children():
			if lamp.has_signal("lamp_collected"):
				lamp.connect("lamp_collected", on_lamp_collected)
				
	# 3. ربط الإشارات من كل الوحوش
	if enemies_container:
		for enemy in enemies_container.get_children():
			if enemy.has_signal("enemy_killed"):
				enemy.connect("enemy_killed", on_enemy_killed)

# دالة بتشتغل لما الولد يجمع مصباح
func on_lamp_collected():
	collected_lamps += 1
	
	# زيادة بسيطة في الإضاءة لكل مصباح
	if not game_finished:
		increase_partial_brightness()
		
	# فحص شرط نهاية اللعبة
	check_game_win_condition()

# دالة بتشتغل لما الولد يقتل وحش
func on_enemy_killed():
	killed_enemies += 1
	
	# فحص شرط نهاية اللعبة
	check_game_win_condition()
	
# دالة بتزيد السطوع شوي شوي مع كل مصباح
func increase_partial_brightness():
	var current_v = canvas_modulate.color.v 
	var target_v = min(current_v + PARTIAL_BRIGHTNESS_STEP, DAY_BRIGHTNESS - PARTIAL_BRIGHTNESS_STEP) # ما توصل للنهار الكامل
	
	var tween = create_tween() 
	tween.tween_property(canvas_modulate, "color:v", target_v, 0.5)

# دالة فحص الفوز وتحويل الخلفية لنهار
func check_game_win_condition():
	if not game_finished and collected_lamps == total_lamps and killed_enemies == total_enemies:
		game_finished = true
		
		# تحويل الإضاءة لـ "نهار" كامل بشكل سلس
		var tween = create_tween() 
		# بنغير قيمة V في اللون لتصير 1.0 (أبيض كامل/نهار)
		tween.tween_property(canvas_modulate, "color:v", DAY_BRIGHTNESS, DAY_TRANSITION_TIME)
		
		print("🎉 مبروك يا ريماس! صار نهار! 🎉")
